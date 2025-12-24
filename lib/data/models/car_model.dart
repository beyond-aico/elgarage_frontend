class CarModel {
  final String id;
  final String make;          // الماركة (Toyota, BMW)
  final String model;         // الموديل (Corolla, X5)
  final String year;          // السنة
  final String imageUrl;      // صورة العربية
  final double currentKm;     // قراءة العداد الحالية
  final double monthlyAvgKm;  // متوسط الاستهلاك الشهري
  final String plateNumber;   // رقم اللوحة (اختياري للعرض)

  // Constructor
  CarModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
    required this.currentKm,
    required this.monthlyAvgKm,
    this.plateNumber = '',
  });

  // دالة بسيطة عشان تعرض اسم العربية كامل
  String get fullName => '$make $model $year';
}