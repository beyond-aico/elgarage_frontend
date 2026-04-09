// lib/core/models/fleet_analytics_model.dart

class FleetAnalytics {
  final double totalFleetCost;
  final double totalFuelConsumedLiters;
  final int totalKmsDriven;
  final double costPerKm;
  // ✅ أضفنا الحقول المطلوبة للهيدر
  final double totalMaintenanceCost;
  final double totalFuelCost;
  final List<VehicleAnalytic> vehicleBreakdown;

  FleetAnalytics({
    required this.totalFleetCost,
    required this.totalFuelConsumedLiters,
    required this.totalKmsDriven,
    required this.costPerKm,
    this.totalMaintenanceCost = 0.0,
    this.totalFuelCost = 0.0,
    required this.vehicleBreakdown,
  });

  factory FleetAnalytics.fromJson(Map<String, dynamic> json) {
    return FleetAnalytics(
      totalFleetCost: (json['totalFleetCost'] as num? ?? 0).toDouble(),
      totalFuelConsumedLiters: (json['totalFuelConsumedLiters'] as num? ?? 0).toDouble(),
      totalKmsDriven: (json['totalKmsDriven'] as num? ?? 0).toInt(),
      costPerKm: (json['costPerKm'] as num? ?? 0).toDouble(),
      // نستخدم totalFleetCost كقيمة مبدئية للوقود كما ظهر في Postman
      totalFuelCost: (json['totalFleetCost'] as num? ?? 0).toDouble(),
      totalMaintenanceCost: 0.0, 
      vehicleBreakdown: json['vehicleBreakdown'] != null
          ? (json['vehicleBreakdown'] as List)
              .map((v) => VehicleAnalytic.fromJson(v))
              .toList()
          : [],
    );
  }
}

class VehicleAnalytic {
  final String carId;
  final String plateNumber;
  final String brand; // ✅ أضفنا البراند
  final String model; // ✅ أضفنا الموديل
  final double totalCost;
  final double fuelLiters;
  final int kms;
  final int remainingKms; // ✅ أضفنا المتبقي للصيانة
  final double nextMaintenanceCost; // ✅ أضفنا التكلفة القادمة

  VehicleAnalytic({
    required this.carId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.totalCost,
    required this.fuelLiters,
    required this.kms,
    required this.remainingKms,
    required this.nextMaintenanceCost,
  });

  factory VehicleAnalytic.fromJson(Map<String, dynamic> json) {
    // حساب افتراضي للمتبقي للصيانة (يمكن للباك إند إرساله لاحقاً)
    int currentKm = (json['lastOdometer'] ?? 0).toInt();
    int remaining = 10000 - (currentKm % 10000); 

    return VehicleAnalytic(
      carId: json['carId']?.toString() ?? '',
      plateNumber: json['plateNumber'] ?? '---',
      brand: json['brand'] ?? 'Unknown', // مطابقة لـ Postman
      model: json['model'] ?? 'Unknown', // مطابقة لـ Postman
      totalCost: (json['totalFuelCost'] ?? 0).toDouble(), // مطابقة لـ Postman
      fuelLiters: (json['totalLiters'] ?? 0).toDouble(), // مطابقة لـ Postman
      kms: currentKm,
      remainingKms: remaining,
      nextMaintenanceCost: 0.0, // سيتم ربطها عند تحديث الباك إند
    );
  }
}