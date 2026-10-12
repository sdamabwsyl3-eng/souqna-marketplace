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
  });
}
