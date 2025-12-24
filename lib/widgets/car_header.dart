import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../data/models/car_model.dart';

class CarHeader extends StatelessWidget {
  final CarModel car;

  const CarHeader({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. أيقونة/صورة العربية (صغيرة)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(car.imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {}, // لو الصورة مش موجودة ما يضربش
                  ),
                ),
                child: car.imageUrl.isEmpty 
                    ? const Icon(CupertinoIcons.car_detailed, size: 30, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 15),

              // 2. تفاصيل الاسم والموديل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.make} ${car.model}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Year: ${car.year} | Plate: ${car.plateNumber.isEmpty ? "N/A" : car.plateNumber}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. شريط المعلومات (عداد الكيلومتر + الصيانة القادمة)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: CupertinoIcons.speedometer,
                  title: 'Current KM',
                  value: '${car.currentKm} km',
                  color: AppColors.primary,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildInfoItem(
                  icon: CupertinoIcons.wrench_fill,
                  title: 'Next Service',
                  value: 'Oct 24', // ده داتا وهمية هنحسبها لاحقاً
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة صغيرة عشان ما نكررش الكود
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}