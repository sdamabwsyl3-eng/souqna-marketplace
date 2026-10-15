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
