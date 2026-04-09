// --- FILE: lib/widgets/car_card.dart ---
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../core/models/car_model.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final bool isSelected;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- الحسابات التقديرية للمعاينه السريعة ---
    // ✅ إصلاح: استخدام mileageKm بدلاً من current وتصحيح العمليات الحسابية
    final int mileageKmValue = car.mileageKm;
    final int nextMaintenanceKm =
        ((mileageKmValue / 10000).floor() + 1) * 10000;
    final int remainingKm = nextMaintenanceKm - mileageKmValue;

    // تحديد حالة اللون بناءً على المسافة المتبقية
    Color healthColor = Colors.greenAccent;
    if (remainingKm < 1000) {
      healthColor = Colors.redAccent;
    } else if (remainingKm < 2500) {
      healthColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withAlpha(5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. قسم الصورة
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                        ? Image.network(
                            car.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // سنة الصنع
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textMain.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        car.year.toString(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. لوحة البيانات (Industrial Info Panel)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.textMain,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.make} ${car.model}'.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getActualCarColor(car.color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${"home.color_label".tr()}: ${car.color != null ? "colors.${car.color!.toLowerCase()}".tr() : "N/A"}'
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(150),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "maintenance.next_service".tr().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "$nextMaintenanceKm KM",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: healthColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: healthColor.withAlpha(100),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                "${'maintenance.remaining'.tr()}: $remainingKm KM",
                                style: TextStyle(
                                  color: healthColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white10, height: 1),

                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.gauge,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${car.mileageKm} KM',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(10),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(100),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            car.licensePlate ?? 'NO PLATE',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActualCarColor(String? colorName) {
    switch (colorName?.toLowerCase().trim()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'red':
        return Colors.red[800]!;
      case 'blue':
        return Colors.blue[900]!;
      case 'navy':
        return const Color(0xFF000080);
      case 'brown':
        return Colors.brown;
      case 'gold':
        return const Color(0xFFFFD700);
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return AppColors.primary;
    }
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/car_logo.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.textMain,
        child: const Center(
          child: Icon(Icons.directions_car, color: Colors.white24, size: 50),
        ),
      ),
    );
  }
}
