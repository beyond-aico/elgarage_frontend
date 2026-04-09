class ServiceLogModel {
  final String id;
  final String serviceName;
  final DateTime date;
  final double mileage;
  final List<String> partsReplaced;
  final double cost; // التأكد من أن الاسم cost وليس totalCost

  ServiceLogModel({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.mileage,
    required this.partsReplaced,
    this.cost = 0.0,
  });

  factory ServiceLogModel.fromJson(Map<String, dynamic> json) {
    String? dateStr = json['serviceDate'] ?? json['date'] ?? json['createdAt'];
    DateTime finalDate = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();

    return ServiceLogModel(
      id: json['id']?.toString() ?? '',
      serviceName: json['serviceName'] ?? 'Maintenance',
      date: finalDate,
      mileage: (json['mileageKm'] ?? json['mileage'] ?? 0).toDouble(),
      partsReplaced: (json['parts'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cost: (json['totalCost'] ?? json['cost'] ?? 0).toDouble(),
    );
  }
}