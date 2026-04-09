class MaintenanceItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String status;
  final int nextDueAt;
  final int lastServiceKm;
  final int nextServiceKm;
  final int remainingKm;
  final int intervalKm; // ✅ مضافة للحسابات

  MaintenanceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    required this.nextDueAt,
    required this.lastServiceKm,
    required this.nextServiceKm,
    required this.remainingKm,
    required this.intervalKm,
  });

  // ✅ دالة copyWith لتصحيح القيم برمجياً
  MaintenanceItem copyWith({
    int? nextDueAt,
    int? remainingKm,
    String? status,
  }) {
    return MaintenanceItem(
      id: id,
      name: name,
      category: category,
      price: price,
      status: status ?? this.status,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      lastServiceKm: lastServiceKm,
      nextServiceKm: nextServiceKm,
      remainingKm: remainingKm ?? this.remainingKm,
      intervalKm: intervalKm,
    );
  }

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) => (val is num) ? val.toInt() : (int.tryParse(val?.toString() ?? '0') ?? 0);

    return MaintenanceItem(
      id: json['serviceName'] ?? '',
      name: json['serviceName'] ?? 'Unknown Service',
      category: json['category'] ?? 'General',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'OK',
      // ✅ تصحيح المفاتيح بناءً على Postman
      nextDueAt: toInt(json['nextDueAtKm']), 
      lastServiceKm: toInt(json['lastPerformedAtKm']),
      nextServiceKm: toInt(json['nextDueAtKm']),
      remainingKm: toInt(json['remainingKm']),
      intervalKm: toInt(json['intervalKm'] ?? 10000),
    );
  }
}