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

    return Car(
      id: json['id']?.toString() ?? '',
      make: makeData,
      model: modelData,
      year: json['year'] is String ? int.tryParse(json['year']) : (json['year'] ?? 0),
      licensePlate: json['plateNumber'] ?? 'No Plate',
      color: json['color'] ?? 'N/A',
      vin: json['vin'],
      imageUrl: json['imageUrl'] ?? '',
      currentKm: json['currentKm'] != null 
          ? (json['currentKm'] is int ? json['currentKm'] : int.tryParse(json['currentKm'].toString()) ?? 0)
          : (json['mileageKm'] is int ? json['mileageKm'] : int.tryParse(json['mileageKm'].toString()) ?? 0),
    );
  }

  get plateNumber => null;
}