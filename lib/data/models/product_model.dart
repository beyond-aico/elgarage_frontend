class ProductModel {
  final String id;
  final String name;       // اسم القطعة (زيت 10 آلاف)
  final double price;      // السعر
  final String category;   // التصنيف (Oils, Filters, Brakes)
  final String? image;     // صورة (اختياري)

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.image,
  });
}