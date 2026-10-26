-- سوقنا: جداول قاعدة البيانات الحقيقية + سياسات أمان الصفوف (RLS)
-- آمن للتشغيل أكثر من مرة (idempotent) — شغّله كامل من: Supabase Dashboard -> SQL Editor -> New query -> Run

-- 1) جدول الملف الشخصي (مرتبط تلقائياً بكل مستخدم يسجّل حساب)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  rating numeric(3, 2) not null default 5.0,
  successful_deals_count integer not null default 0,
  wallet_balance numeric(12, 2) not null default 0,
  escrow_balance numeric(12, 2) not null default 0,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles are publicly readable" on public.profiles;
create policy "profiles are publicly readable"
  on public.profiles for select
  using (true);

drop policy if exists "users can update their own profile" on public.profiles;
create policy "users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- إنشاء صف profile تلقائياً عند تسجيل أي مستخدم جديد
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2) جدول السلع المعروضة
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'أجهزة وإلكترونيات',
  price numeric(12, 2) not null,
  is_negotiable boolean not null default true,
  condition text not null default 'جديد',
  city text not null, -- الولاية
  district text not null default '',
  images text[] not null default '{}',
  is_inspected boolean not null default false,
  has_escrow boolean not null default true,
  status text not null default 'active', -- active | sold | draft
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

drop policy if exists "products are publicly readable" on public.products;
create policy "products are publicly readable"
  on public.products for select
  using (true);

drop policy if exists "sellers can insert their own products" on public.products;
create policy "sellers can insert their own products"
  on public.products for insert
  with check (auth.uid() = seller_id);

drop policy if exists "sellers can update their own products" on public.products;
create policy "sellers can update their own products"
  on public.products for update
  using (auth.uid() = seller_id);

drop policy if exists "sellers can delete their own products" on public.products;
create policy "sellers can delete their own products"
  on public.products for delete
  using (auth.uid() = seller_id);

-- 3) جدول عمليات المحفظة
create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  amount numeric(12, 2) not null,
  type text not null, -- deposit | withdrawal | escrow_hold | escrow_released
  reference_number text not null default '',
  status text not null default 'معلّق',
  created_at timestamptz not null default now()
);

alter table public.wallet_transactions enable row level security;

drop policy if exists "users can read their own transactions" on public.wallet_transactions;
create policy "users can read their own transactions"
  on public.wallet_transactions for select
  using (auth.uid() = user_id);

drop policy if exists "users can insert their own transactions" on public.wallet_transactions;
create policy "users can insert their own transactions"
  on public.wallet_transactions for insert
  with check (auth.uid() = user_id);

-- يحدّث رصيد المحفظة/الضمان في profiles تلقائياً كل ما تُدرج عملية محفظة جديدة
create or replace function public.apply_wallet_transaction()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.type = 'deposit' then
    update public.profiles set wallet_balance = wallet_balance + new.amount where id = new.user_id;
  elsif new.type = 'withdrawal' then
    update public.profiles set wallet_balance = wallet_balance - new.amount where id = new.user_id;
  elsif new.type = 'escrow_hold' then
    update public.profiles set escrow_balance = escrow_balance + new.amount where id = new.user_id;
  elsif new.type = 'escrow_released' then
    update public.profiles set escrow_balance = escrow_balance - new.amount where id = new.user_id;
  end if;
  return new;
end;
$$;

drop trigger if exists on_wallet_transaction_insert on public.wallet_transactions;
create trigger on_wallet_transaction_insert
  after insert on public.wallet_transactions
  for each row execute procedure public.apply_wallet_transaction();

-- 4) جدول الحسابات البنكية الخاصة بالمستخدم (للسحب)
create table if not exists public.bank_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  bank_name text not null,
  account_number text not null,
  created_at timestamptz not null default now()
);

alter table public.bank_accounts enable row level security;

drop policy if exists "users can read their own bank accounts" on public.bank_accounts;
create policy "users can read their own bank accounts"
  on public.bank_accounts for select
  using (auth.uid() = user_id);

drop policy if exists "users can insert their own bank accounts" on public.bank_accounts;
create policy "users can insert their own bank accounts"
  on public.bank_accounts for insert
  with check (auth.uid() = user_id);

drop policy if exists "users can delete their own bank accounts" on public.bank_accounts;
create policy "users can delete their own bank accounts"
  on public.bank_accounts for delete
  using (auth.uid() = user_id);

-- 5) جدول الطلبات (الشراء بضمان سوقنا)
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  buyer_id uuid not null references public.profiles (id) on delete cascade,
  seller_id uuid not null references public.profiles (id) on delete cascade,
  price numeric(12, 2) not null,
  escrow_fee numeric(12, 2) not null,
  total numeric(12, 2) not null,
  payment_method text not null,
  status text not null default 'escrow_held', -- escrow_held | in_progress | completed
  step int not null default 0, -- 0..4 يطابق مراحل تتبع الطلب بالتطبيق
  created_at timestamptz not null default now()
);

alter table public.orders enable row level security;

drop policy if exists "buyers and sellers can read their orders" on public.orders;
create policy "buyers and sellers can read their orders"
  on public.orders for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- لا إدراج/تعديل مباشر من العميل على orders أو wallet_transactions الخاصة بطرف آخر؛
-- كل ذلك يمر عبر الدالتين الآمنتين أدناه (security definer).

-- إنشاء طلب شراء بضمان: يحجز المبلغ في ضمان المشتري ويقفل السلعة عن العرض
create or replace function public.create_order(p_product_id uuid, p_payment_method text)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  v_product public.products%rowtype;
  v_order_id uuid;
  v_fee numeric(12, 2);
  v_total numeric(12, 2);
begin
  select * into v_product from public.products where id = p_product_id;
  if not found then
    raise exception 'السلعة غير موجودة';
  end if;
  if v_product.status <> 'active' then
    raise exception 'السلعة لم تعد متاحة';
  end if;

  v_fee := round(v_product.price * 0.01, 2);
  v_total := v_product.price + v_fee;

  insert into public.orders (product_id, buyer_id, seller_id, price, escrow_fee, total, payment_method)
  values (p_product_id, auth.uid(), v_product.seller_id, v_product.price, v_fee, v_total, p_payment_method)
  returning id into v_order_id;

  insert into public.wallet_transactions (user_id, title, amount, type, reference_number, status)
  values (auth.uid(), 'حجز مبلغ في الضمان - ' || v_product.title, v_total, 'escrow_hold',
          'SQ-' || upper(substr(v_order_id::text, 1, 8)), 'معلّق');

  update public.products set status = 'sold' where id = p_product_id;

  return v_order_id;
end;
$$;

-- التقدّم بمراحل الطلب؛ عند الوصول للمرحلة الأخيرة يُحرَّر المبلغ من ضمان المشتري لمحفظة البائع
create or replace function public.advance_order(p_order_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  v_order public.orders%rowtype;
  v_title text;
begin
  select * into v_order from public.orders where id = p_order_id;
  if not found then
    raise exception 'الطلب غير موجود';
  end if;
  if v_order.buyer_id <> auth.uid() then
    raise exception 'غير مصرح لك بتحديث هذا الطلب';
  end if;
  if v_order.step >= 4 then
    return;
  end if;

  select title into v_title from public.products where id = v_order.product_id;

  update public.orders
    set step = step + 1,
        status = case when step + 1 >= 4 then 'completed' else 'in_progress' end
    where id = p_order_id;

  if v_order.step + 1 >= 4 then
    insert into public.wallet_transactions (user_id, title, amount, type, reference_number, status)
    values (v_order.buyer_id, 'تحرير مبلغ من الضمان - ' || coalesce(v_title, ''), v_order.total, 'escrow_released',
            'SQ-' || upper(substr(p_order_id::text, 1, 8)), 'مكتمل');

    insert into public.wallet_transactions (user_id, title, amount, type, reference_number, status)
    values (v_order.seller_id, 'استلام ثمن البيع - ' || coalesce(v_title, ''), v_order.price, 'deposit',
            'SQ-' || upper(substr(p_order_id::text, 1, 8)), 'مكتمل');
  end if;
end;
$$;

grant execute on function public.create_order(uuid, text) to authenticated;
grant execute on function public.advance_order(uuid) to authenticated;

-- 6) السلع المفضّلة لدى المستخدم (قائمة "المفضلة" في الشريط السفلي)
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table public.favorites enable row level security;

drop policy if exists "users manage their own favorites" on public.favorites;
create policy "users manage their own favorites"
  on public.favorites for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 7) محادثات التفاوض على السلع (تبويب "المحادثات")، ورسائلها
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  buyer_id uuid not null references public.profiles (id) on delete cascade,
  seller_id uuid not null references public.profiles (id) on delete cascade,
  last_message text not null default '',
  last_message_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (product_id, buyer_id)
);

alter table public.conversations enable row level security;

drop policy if exists "participants can view their conversations" on public.conversations;
create policy "participants can view their conversations"
  on public.conversations for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

drop policy if exists "buyers can start a conversation" on public.conversations;
create policy "buyers can start a conversation"
  on public.conversations for insert
  with check (auth.uid() = buyer_id and auth.uid() <> seller_id);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  text text not null,
  created_at timestamptz not null default now()
);

alter table public.messages enable row level security;

drop policy if exists "participants can view conversation messages" on public.messages;
create policy "participants can view conversation messages"
  on public.messages for select
  using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

drop policy if exists "participants can send conversation messages" on public.messages;
create policy "participants can send conversation messages"
  on public.messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.conversations c
      where c.id = conversation_id and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- عند إرسال رسالة جديدة، حدّث معاينة آخر رسالة على المحادثة تلقائياً.
create or replace function public.handle_new_message()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.conversations
    set last_message = new.text,
        last_message_at = new.created_at
    where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists on_new_message on public.messages;
create trigger on_new_message
  after insert on public.messages
  for each row execute procedure public.handle_new_message();
