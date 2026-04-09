import 'package:flutter/material.dart';
import 'package:elgarage/core/services/car_service.dart';
import '../core/models/maintenance_item_model.dart';
import '../core/models/service_log_model.dart';
import '../core/models/product_model.dart';

class MaintenanceProvider with ChangeNotifier {
  final CarService _carService = CarService();

  // --- الحالة (State) ---
  List<MaintenanceItem> _dueMaintenance = [];
  List<ServiceLogModel> _serviceHistory = [];
  bool _isLoadingMaintenance = false;
  int _notificationThreshold = 1000;

  // --- Getters ---
  List<MaintenanceItem> get dueMaintenance => _dueMaintenance;
  List<ServiceLogModel> get serviceHistory => _serviceHistory;
  bool get isLoadingMaintenance => _isLoadingMaintenance;
  int get notificationThreshold => _notificationThreshold;

  // --- التحليلات (Analytics) لصفحة My Car والأسطول ---

  // حساب حالة العربية (Healthy vs Issues)
  String get carHealthScore {
    if (_dueMaintenance.isEmpty) return "HEALTHY";
    bool hasOverdueItems = _dueMaintenance.any(
      (item) => item.status == 'OVERDUE',
    );
    return hasOverdueItems ? "ISSUES" : "HEALTHY";
  }

  // إجمالي المصاريف من سجل الصيانة
  double get totalExpenses {
    if (_serviceHistory.isEmpty) return 0.0;
    return _serviceHistory.fold(0.0, (sum, item) => sum + item.cost);
  }

  int get nextServiceRemainingKm {
    if (_dueMaintenance.isEmpty) return 0;

    // إزالة التحقق من null لأن الحقل أصبح required في الموديل
    final allItems = _dueMaintenance.toList();

    // ترتيب تنازلي لأقرب مسافة
    allItems.sort((a, b) => a.remainingKm.compareTo(b.remainingKm));
    return allItems.first.remainingKm;
  }

  // ✅ حساب الـ Milestone الحالي (نظام الـ 10 آلاف الافتراضي للعرض)
  int getCurrentMilestone(int mileageKm) {
    if (mileageKm == 0) return 10000;
    return ((mileageKm / 10000).floor() + 1) * 10000;
  }

  // الحالة الصحية التفصيلية بناءً على حد الإشعارات
  String get realHealthStatus {
    if (_dueMaintenance.isEmpty) return "UP TO DATE";
    if (_dueMaintenance.any((item) => item.status == 'OVERDUE')) {
      return "OVERDUE";
    }

    int remaining = nextServiceRemainingKm;
    if (remaining <= _notificationThreshold) return "SOON";
    return "UP TO DATE";
  }

  Future<void> fetchDueMaintenance(String carId, int mileageKm) async {
    _isLoadingMaintenance = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _carService.getDueMaintenance(carId);

      _dueMaintenance = data.map((itemJson) {
        var item = MaintenanceItem.fromJson(itemJson);

        // 🟢 تصحيح الأرقام السالبة للمستخدم الجديد برمجياً
        if (item.status == 'OVERDUE' && item.lastServiceKm == 0) {
          int nextLogicalDue =
              ((mileageKm / item.intervalKm).floor() + 1) * item.intervalKm;
          int correctedRemaining = nextLogicalDue - mileageKm;

          return item.copyWith(
            nextDueAt: nextLogicalDue,
            remainingKm: correctedRemaining,
            status: correctedRemaining <= _notificationThreshold
                ? 'SOON'
                : 'OK',
          );
        }
        return item;
      }).toList();
    } catch (e) {
      debugPrint("❌ Maintenance Fetch Error: $e");
    } finally {
      _isLoadingMaintenance = false;
      notifyListeners();
    }
  }

  // جلب سجل الصيانة التاريخي
  Future<void> fetchServiceHistory(String carId) async {
    try {
      final rawData = await _carService.getServiceHistory(carId);
      _serviceHistory = rawData
          .map((json) => ServiceLogModel.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ History Mapping Error: $e");
    }
  }

  void addServiceLog(dynamic logData) {
    if (logData is Map) {
      // تحويل الـ Map بشكل صريح ليتوافق مع الموديل
      _serviceHistory.insert(
        0,
        ServiceLogModel.fromJson(Map<String, dynamic>.from(logData)),
      );
    }
    notifyListeners();
  }

  List<ProductModel> getMaintenanceItemsFor(int milestone) {
    var apiItems = _dueMaintenance
        .where((item) {
          int roundedNextDue = (item.nextDueAt / 10000).round() * 10000;

          // أظهر القطعة إذا كانت في ميعادها المظبوط
          // أو إذا كانت حالة السيرفر لها OVERDUE ووصلنا لتبويب الـ Recommended
          if (item.status == 'OVERDUE') {
            return milestone >= roundedNextDue;
          }

          return roundedNextDue == milestone;
        })
        .map((item) {
          return ProductModel(
            id: item.id,
            name: item.name,
            price: item.price > 0 ? item.price : _getPriceForPart(item.name),
            category: item.category,
            imagePath: getImageForPart(item.name),
            isMissed: item.status == 'OVERDUE',
          );
        })
        .toList();

    return apiItems;
  }
  // --- Helpers (مساعدة العرض) ---

  double _getPriceForPart(String name) {
    name = name.toLowerCase();
    if (name.contains('oil') && !name.contains('filter')) return 1500;
    if (name.contains('filter')) return 400;
    if (name.contains('spark')) return 1000;
    if (name.contains('belt')) return 3000;
    if (name.contains('coolant')) return 600;
    return 500;
  }

  String getImageForPart(String partName) {
    String name = partName.toLowerCase();
    if (name.contains('oil')) return 'assets/images/engine_oil.png';
    if (name.contains('spark')) return 'assets/images/spark_plug.png';
    if (name.contains('brake')) return 'assets/images/brake_pad.png';
    return 'assets/images/engine_oil.png';
  }

  // ضبط حد الإشعارات
  void setNotificationThreshold(int km) {
    _notificationThreshold = km;
    notifyListeners();
  }

  void clearMaintenanceData() {
    _dueMaintenance = [];
    _serviceHistory = [];
    _isLoadingMaintenance = false;
    notifyListeners();
  }
}
