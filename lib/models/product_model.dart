class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String city;
  final String district;
  final String condition;
  final bool isInspected;
  final bool hasEscrow;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final double sellerRating;
  final int sellerDealsCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.category = 'أجهزة وإلكترونيات',
    required this.city,
    required this.district,
    required this.condition,
    this.isInspected = true,
    this.hasEscrow = true,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRating,
    required this.sellerDealsCount,
    required this.createdAt,
  });

  /// يبني Product من صف جدول products في Supabase، بعد عمل join بسيط مع
  /// جدول profiles (البائع) تحت اسم seller في الاستعلام.
  factory Product.fromJson(Map<String, dynamic> j) {
    final seller = j['seller'] as Map<String, dynamic>?;
    final name = (seller?['full_name'] as String?)?.trim();
    final imgs = (j['images'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    return Product(
      id: j['id'] as String,
      title: j['title'] as String,
      price: (j['price'] as num).toDouble(),
      category: j['category'] as String? ?? 'أجهزة وإلكترونيات',
      city: j['city'] as String? ?? '',
      district: j['district'] as String? ?? '',
      condition: j['condition'] as String? ?? 'جديد',
      isInspected: j['is_inspected'] as bool? ?? false,
      hasEscrow: j['has_escrow'] as bool? ?? true,
      images: imgs.isNotEmpty
          ? imgs
          : const ['https://images.unsplash.com/photo-1472851294608-062f824d29cc?q=80&w=600&auto=format&fit=crop'],
      sellerId: j['seller_id'] as String,
      sellerName: (name != null && name.isNotEmpty) ? name : 'بائع سوقنا',
      sellerRating: (seller?['rating'] as num?)?.toDouble() ?? 5.0,
      sellerDealsCount: seller?['successful_deals_count'] as int? ?? 0,
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }

  /// نص تاريخ نسبي قصير لعرضه على بطاقة السلعة (مثل "اليوم"، "قبل 3 أيام").
  String get postedAgoLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return diff.inMinutes <= 1 ? 'الآن' : 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    if (diff.inDays < 7) return diff.inDays == 1 ? 'أمس' : 'قبل ${diff.inDays} أيام';
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}';
  }
}
