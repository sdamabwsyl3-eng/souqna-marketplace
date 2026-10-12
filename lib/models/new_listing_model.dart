class NewListingModel {
  String title;
  String description;
  String category;
  double price;
  bool isNegotiable;
  String condition;
  String city;
  String district;
  List<String> imagePaths;
  bool enableEscrow;
  bool requestTechnicalInspection;
  String deliveryMethod;

  NewListingModel({
    this.title = '',
    this.description = '',
    this.category = 'أجهزة وإلكترونيات',
    this.price = 0.0,
    this.isNegotiable = true,
    this.condition = 'كالجديد',
    this.city = 'الرياض',
    this.district = '',
    this.imagePaths = const [],
    this.enableEscrow = true,
    this.requestTechnicalInspection = false,
    this.deliveryMethod = 'شحن وتوصيل مع فحص',
  });
}
