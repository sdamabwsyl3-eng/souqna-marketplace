import 'package:supabase_flutter/supabase_flutter.dart';

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
}
