import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../core/models/car_model.dart';

class CarHeader extends StatelessWidget {
  final Car car;

  const CarHeader({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.textMain, // Asphalt Dark لإعطاء طابع صناعي
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. صورة العربية أو اللوجو
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(car.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _defaultIcon()),
                      )
                    : _defaultIcon(),
              ),
              const SizedBox(width: 15),

              // 2. الاسم والموديل مع حماية الـ Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.make} ${car.model}'.toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Year: ${car.year} | ${car.licensePlate ?? "No Plate"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. شريط المعلومات الحقيقي
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(03),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: CupertinoIcons.speedometer,
                  title: 'Current KM',
                  value: '${car.currentKm.toInt()} km',
                  color: AppColors.primary,
                ),
                Container(width: 1, height: 30, color: Colors.white10),
                _buildInfoItem(
                  icon: CupertinoIcons.wrench_fill,
                  title: 'Next Service',
                  value: 'Soon',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultIcon() => const Icon(CupertinoIcons.car_detailed, size: 30, color: AppColors.primary);

  Widget _buildInfoItem({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}