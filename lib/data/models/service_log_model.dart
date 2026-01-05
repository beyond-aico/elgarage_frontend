class ServiceLogModel {
  final String id;
  final String serviceName; 
  final DateTime date;
  final double mileage; // <--- Added this
  final List<String> partsReplaced; // <--- Added this
  final double cost;

  ServiceLogModel({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.mileage,
    required this.partsReplaced,
    this.cost = 0.0,
  });
}