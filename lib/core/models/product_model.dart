class ProductModel {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String category; // e.g., 'spare_parts', 'oil', 'service'

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  // لتحويل البيانات من وإلى Firebase لاحقاً
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}