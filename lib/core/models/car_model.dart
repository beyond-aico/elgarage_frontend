class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? licensePlate;
  final String? color;
  final String? vin;
  final String? imageUrl;
  final int mileageKm; // سنبقي الاسم mileageKm لتقليل أخطاء الـ UI
  final String? userId; // ✅ أضف هذا الحقل

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.licensePlate,
    this.color,
    this.vin,
    this.imageUrl,
    this.mileageKm = 0,
    this.userId, // ✅ أضفه هنا
  });

  Car copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? color,
    String? vin,
    String? imageUrl,
    int? mileageKm,
    String? userId, // ✅ أضفه هنا
  }) {
    return Car(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      imageUrl: imageUrl ?? this.imageUrl,
      mileageKm: mileageKm ?? this.mileageKm,
      userId: userId ?? this.userId, // ✅ أضفه هنا
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    // تعريف المتغيرات التي كانت ناقصة في التشخيص
    String makeData = 'Unknown Make';
    String modelData = 'Unknown Model';

    if (json['model'] != null && json['model'] is Map) {
      modelData = json['model']['name'] ?? 'Unknown Model';
      if (json['model']['brand'] != null && json['model']['brand'] is Map) {
        makeData = json['model']['brand']['name'] ?? 'Unknown Make';
      }
    } else {
      makeData = json['make'] ?? 'Unknown Make';
      modelData = json['model'] is String ? json['model'] : 'Unknown Model';
    }

    final dynamic rawKm =
        json['mileageKm'] ?? json['mileageKm'] ?? json['mileage'] ?? 0;
    final int finalKm = (rawKm is num)
        ? rawKm.toInt()
        : int.tryParse(rawKm.toString()) ?? 0;

    return Car(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(), // ✅ السطر السحري للربط
      make: makeData,
      model: modelData,
      year: json['year'] ?? 2024,
      licensePlate: json['plateNumber'] ?? json['licensePlate'],
      color: json['color'],
      vin: json['vin'],
      imageUrl: json['imageUrl'] ?? '',
      mileageKm: finalKm,
    );
  }
}
