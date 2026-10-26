import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/user_profile_model.dart';

/// طبقة وصول موحّدة لبيانات سوقنا الحقيقية في Supabase
/// (الملف الشخصي، السلع، عمليات المحفظة) بدل البيانات التجريبية MockData.
class SupabaseDataService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// يجلب الملف الشخصي للمستخدم الحالي، أو null لو مسجّل خروج.
  static Future<UserProfile?> fetchMyProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (row == null) return null;
    return UserProfile.fromJson(row);
  }

  /// يجلب كل السلع النشطة مع بيانات البائع (الاسم، التقييم، عدد الصفقات).
  static Future<List<Product>> fetchProducts() async {
    final rows = await _client
        .from('products')
        .select('*, seller:profiles!seller_id(full_name, rating, successful_deals_count)')
        .eq('status', 'active')
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Product.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// ينشر سلعة جديدة باسم المستخدم الحالي.
  static Future<void> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required bool isNegotiable,
    required String condition,
    required String city,
    required String district,
    required List<String> images,
    required bool hasEscrow,
    required bool isInspected,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    await _client.from('products').insert({
      'seller_id': uid,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'is_negotiable': isNegotiable,
      'condition': condition,
      'city': city,
      'district': district,
      'images': images,
      'has_escrow': hasEscrow,
      'is_inspected': isInspected,
    });
  }

  /// يجلب سجل عمليات المحفظة للمستخدم الحالي، الأحدث أولاً.
  static Future<List<WalletTransaction>> fetchMyWalletTransactions() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('wallet_transactions')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => WalletTransaction.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// ينشئ طلب شراء بضمان سوقنا: يحجز المبلغ في ضمان المشتري، يقفل السلعة
  /// عن العرض، ويرجّع معرّف الطلب الجديد. (دالة قاعدة بيانات آمنة create_order)
  static Future<String> createOrder({
    required String productId,
    required String paymentMethod,
  }) async {
    final res = await _client.rpc('create_order', params: {
      'p_product_id': productId,
      'p_payment_method': paymentMethod,
    });
    return res as String;
  }

  /// يجلب تفاصيل طلب واحد (لصفحة تتبع الطلب).
  static Future<Map<String, dynamic>> fetchOrder(String orderId) async {
    final row = await _client.from('orders').select().eq('id', orderId).single();
    return row;
  }

  /// يتقدّم بالطلب لمرحلة تالية؛ عند آخر مرحلة يحرّر المبلغ لمحفظة البائع.
  /// (دالة قاعدة بيانات آمنة advance_order)
  static Future<void> advanceOrder(String orderId) async {
    await _client.rpc('advance_order', params: {'p_order_id': orderId});
  }

  /// يجلب الحسابات البنكية المسجّلة للمستخدم الحالي.
  static Future<List<Map<String, dynamic>>> fetchMyBankAccounts() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('bank_accounts')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// يضيف حساباً بنكياً جديداً للمستخدم الحالي.
  static Future<void> addBankAccount({
    required String bankName,
    required String accountNumber,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    await _client.from('bank_accounts').insert({
      'user_id': uid,
      'bank_name': bankName,
      'account_number': accountNumber,
    });
  }

  /// يحذف حساباً بنكياً.
  static Future<void> deleteBankAccount(String id) async {
    await _client.from('bank_accounts').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------
  // المفضّلة
  // ---------------------------------------------------------------------

  /// يجلب معرّفات السلع المفضّلة لدى المستخدم الحالي (لتلوين أيقونة القلب).
  static Future<Set<String>> fetchMyFavoriteProductIds() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return {};
    final rows = await _client.from('favorites').select('product_id').eq('user_id', uid);
    return (rows as List<dynamic>).map((r) => r['product_id'] as String).toSet();
  }

  /// يبدّل حالة المفضّلة لسلعة: يضيفها لو غير موجودة، ويحذفها لو موجودة.
  /// يرجّع الحالة الجديدة (true = أصبحت مفضّلة).
  static Future<bool> toggleFavorite(String productId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', uid)
        .eq('product_id', productId)
        .maybeSingle();
    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id'] as String);
      return false;
    } else {
      await _client.from('favorites').insert({'user_id': uid, 'product_id': productId});
      return true;
    }
  }

  /// يجلب السلع المفضّلة الكاملة (مع بيانات البائع) لتبويب "المفضلة".
  static Future<List<Product>> fetchMyFavoriteProducts() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('favorites')
        .select('product:products(*, seller:profiles!seller_id(full_name, rating, successful_deals_count))')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => r['product'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map((p) => Product.fromJson(p))
        .toList();
  }

  // ---------------------------------------------------------------------
  // المحادثات والرسائل
  // ---------------------------------------------------------------------

  /// يجلب محادثة قائمة لسلعة معيّنة أو ينشئ واحدة جديدة (المستخدم الحالي
  /// يكون دائماً المشتري هنا؛ لا يمكنه فتح محادثة على سلعته هو).
  static Future<String> getOrCreateConversation({
    required String productId,
    required String sellerId,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    if (uid == sellerId) throw Exception('لا يمكنك محادثة نفسك على سلعتك');

    final existing = await _client
        .from('conversations')
        .select('id')
        .eq('product_id', productId)
        .eq('buyer_id', uid)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final row = await _client
        .from('conversations')
        .insert({'product_id': productId, 'buyer_id': uid, 'seller_id': sellerId})
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// يجلب كل محادثات المستخدم الحالي (بائعاً كان أو مشترياً)، الأحدث أولاً.
  static Future<List<Conversation>> fetchMyConversations() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('conversations')
        .select(
          'id, product_id, buyer_id, seller_id, last_message, last_message_at, '
          'product:products(title, images), '
          'buyer:profiles!buyer_id(full_name), '
          'seller:profiles!seller_id(full_name)',
        )
        .or('buyer_id.eq.$uid,seller_id.eq.$uid')
        .order('last_message_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Conversation.fromJson(r as Map<String, dynamic>, uid))
        .toList();
  }

  /// يجلب كل رسائل محادثة معيّنة بترتيب زمني تصاعدي.
  static Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return (rows as List<dynamic>).map((r) => ChatMessage.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// يرسل رسالة جديدة في محادثة (يحدّث معاينة آخر رسالة تلقائياً عبر trigger).
  static Future<ChatMessage> sendMessage({required String conversationId, required String text}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('يجب تسجيل الدخول أولاً');
    final row = await _client
        .from('messages')
        .insert({'conversation_id': conversationId, 'sender_id': uid, 'text': text})
        .select()
        .single();
    return ChatMessage.fromJson(row);
  }
}
