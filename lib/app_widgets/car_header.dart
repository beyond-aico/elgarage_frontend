// --- FILE: lib/widgets/car_header.dart ---
import 'package:elgarage/providers/fleet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/car_model.dart';
import '../providers/app_provider.dart';
import '../providers/maintenance_provider.dart'; // ✅ إضافة الاستيراد الجديد

class CarHeader extends StatelessWidget {
  final Car car;
final bool disableKmUpdate;

const CarHeader({super.key, required this.car, this.disableKmUpdate = false, required bool hideVehicleInfo});
  @override
  Widget build(BuildContext context) {
    // 1. استدعاء البروفايدرز
    final appProvider = Provider.of<AppProvider>(context);
    final mainProvider = Provider.of<MaintenanceProvider>(context);
final fleetProvider = Provider.of<FleetProvider>(context, listen: false);    final int remaining = mainProvider.nextServiceRemainingKm;
    final String healthStatus = mainProvider.realHealthStatus;

    Color statusColor;
    IconData statusIcon;

    if (healthStatus == 'OVERDUE') {
      statusColor = Colors.redAccent;
      statusIcon = CupertinoIcons.exclamationmark_triangle_fill;
    } else if (healthStatus == 'SOON') {
      statusColor = AppColors.primary;
      statusIcon = CupertinoIcons.wrench_fill;
    } else {
      statusColor = Colors.greenAccent;
      statusIcon = CupertinoIcons.checkmark_seal_fill;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.car_detailed,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${car.make} ${car.model}".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      car.licensePlate ?? "---",
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // 1. الكيلومتر الحالي (عبر AppProvider)
                _buildCompactInfo(
                  CupertinoIcons.speedometer,
                  'CURRENT KM',
                  '${car.mileageKm}',
                  AppColors.primary,
               onTap: disableKmUpdate ? null : () => _showUpdateKmDialog(context, appProvider, mainProvider, fleetProvider),
                ),
                _divider(),

                // 2. الحالة (عبر MaintenanceProvider)
                _buildCompactInfo(
                  statusIcon,
                  'STATUS',
                  healthStatus,
                  statusColor,
                ),
                _divider(),

                // 3. المسافة المتبقية (عبر MaintenanceProvider)
                _buildCompactInfo(
                  CupertinoIcons.hourglass,
                  'REMAINING',
                  '$remaining KM',
                  AppColors.primary,
                  onTap: () =>
                      _showNotificationThresholdSheet(context, mainProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 15,
    color: Colors.white10,
    margin: const EdgeInsets.symmetric(horizontal: 5),
  );

  Widget _buildCompactInfo(
    IconData icon,
    String title,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: color.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 12),
                const SizedBox(width: 4),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 7,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- دوال الأكشن المحدثة ---

  void _showUpdateKmDialog(
    BuildContext context,
    AppProvider appProvider,
    MaintenanceProvider mainProvider,
    FleetProvider fleetProvider, // ✅ إضافة البارامتر الجديد هنا
  ) {
    final TextEditingController kmController = TextEditingController(
      text: car.mileageKm.toString(),
    );
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Update Odometer"),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: CupertinoTextField(
            controller: kmController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
CupertinoDialogAction(
  child: const Text("Update"),
  onPressed: () async {
    int? newKm = int.tryParse(kmController.text);
    if (newKm != null) {
      Navigator.pop(context);
      
      // ✅ التعديل هنا: مرر fleetProvider اللي إنت استلمته في بارامترات الدالة
      bool success = await appProvider.updateCarCurrentKm(
        newKm, 
        fleetProvider: fleetProvider, // هكذا يتم الربط اللحظي
      );

      if (success) {
        await mainProvider.fetchDueMaintenance(car.id, newKm);
      }
    }
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationThresholdSheet(
    BuildContext context,
    MaintenanceProvider mainProvider,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Notify me before maintenance by:"),
        actions: [500, 1000, 2000]
            .map(
              (km) => CupertinoActionSheetAction(
                child: Text("$km KM"),
                onPressed: () {
                  // استخدام MaintenanceProvider لضبط الإشعارات
                  mainProvider.setNotificationThreshold(km);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
