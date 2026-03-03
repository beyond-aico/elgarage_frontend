class MaintenanceItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool isMissed;
  final String status; // الحالات: OK, DUE_SOON, OVERDUE
  final int? remainingKm; // المسافة المتبقية

  MaintenanceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.isMissed = false,
    required this.status,
    this.remainingKm,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: json['serviceName'] ?? DateTime.now().toString(),
      name: json['serviceName'] ?? 'Unknown Service',
      category: json['category'] ?? 'General',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      // نعتبره Overdue لو السيرفر بعت الحالة دي
      isMissed: json['status'] == 'OVERDUE', 
      status: json['status'] ?? 'OK',
      remainingKm: json['remainingKm'], // سحب المسافة من الباك إند
    );
  }
}