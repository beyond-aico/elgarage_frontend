class ServiceLogModel {
  final String id;
  final String serviceName; // اسم الصيانة (تغيير زيت، صيانة 10 آلاف..)
  final DateTime date;      // تاريخ الصيانة
  final double cost;        // التكلفة (اختياري حالياً)
  final String notes;       // ملاحظات

  ServiceLogModel({
    required this.id,
    required this.serviceName,
    required this.date,
    this.cost = 0.0,
    this.notes = '',
  });
}