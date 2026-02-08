class MaintenanceItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool isMissed;
  final String status;

  MaintenanceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.isMissed = false,
    required this.status,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Service',
      category: json['category'] ?? 'General',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      isMissed: json['isMissed'] ?? false,
      status: json['status'] ?? 'PENDING',
    );
  }
}