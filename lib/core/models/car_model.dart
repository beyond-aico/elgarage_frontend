class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? licensePlate;
  final String? color;
  final String? vin;
  final String? imageUrl;
  final int currentKm;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.licensePlate,
    this.color,
    this.vin,
    this.imageUrl,
    this.currentKm = 0,
  });

factory Car.fromJson(Map<String, dynamic> json) {
    String makeData = 'Unknown Make';
    String modelData = 'Unknown Model';

    // 1. استخراج البيانات من الكائن المتداخل model (وهذا هو الأصح حسب الباك إند الحالي)
    if (json['model'] != null && json['model'] is Map) {
      modelData = json['model']['name'] ?? 'Unknown Model';
      
      // الدخول لعمق أكبر لجلب الماركة
      if (json['model']['brand'] != null && json['model']['brand'] is Map) {
        makeData = json['model']['brand']['name'] ?? 'Unknown Make';
      }
    } 
    // 2. محاولة القراءة المباشرة (احتياطي)
    else {
      makeData = json['make'] ?? 'Unknown Make';
      modelData = json['model'] is String ? json['model'] : 'Unknown Model';
    }

    // ✅ التعديل الجوهري لضمان قراءة العداد من أي حقل يرسله السيرفر
  final dynamic rawKm = json['currentKm'] ?? json['mileageKm'] ?? json['mileage'] ?? 0;
  final int finalKm = (rawKm is num) ? rawKm.toInt() : int.tryParse(rawKm.toString()) ?? 0;

  return Car(
    id: json['id']?.toString() ?? '',
    make: makeData,
    model: modelData,
    year: json['year'] ?? 2024,
    licensePlate: json['plateNumber'] ?? 'No Plate',
    color: json['color'] ?? 'N/A',
    imageUrl: json['imageUrl'] ?? '',
    currentKm: finalKm, // القيمة الموحدة
  );
}

  Null get plateNumber => null;
}