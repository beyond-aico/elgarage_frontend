class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? image;
  final String? imagePath;
  bool isMissed;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.image,
    this.imagePath,
    this.isMissed = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category'] ?? '',
      image: json['image'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'imagePath': imagePath,
    };
  }
}