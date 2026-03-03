// --- FILE: lib/widgets/car_header.dart ---

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; // ✅ إضافة Provider
import '../core/constants/app_colors.dart';
import '../core/models/car_model.dart';
import '../providers/app_provider.dart'; // ✅ إضافة الـ Provider
// ✅ إضافة الموديل

class CarHeader extends StatelessWidget {
  final Car car;

  const CarHeader({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    // ✅ استدعاء الـ Provider لجلب بيانات الصيانة
    final provider = Provider.of<AppProvider>(context);
    
    // حساب أقرب صيانة (أقل عدد كيلومترات متبقي)
    String nextServiceText = "Healthy";
    Color serviceColor = AppColors.primary;

    if (provider.dueMaintenance.isNotEmpty) {
      // البحث عن أقل remainingKm بشرط ميكونش OK
      final dueItems = provider.dueMaintenance.where((i) => i.status != 'OK').toList();
      if (dueItems.isNotEmpty) {
        dueItems.sort((a, b) => (a.remainingKm ?? 999999).compareTo(b.remainingKm ?? 999999));
        final closest = dueItems.first;
        
        nextServiceText = closest.status == 'OVERDUE' 
            ? 'OVERDUE' 
            : '${closest.remainingKm} km';
        
        serviceColor = closest.status == 'OVERDUE' ? Colors.red : AppColors.warning;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
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
                  icon: closestStatusIcon(provider), // ✅ تغيير الأيقونة حسب الحالة
                  title: 'Next Service',
                  value: nextServiceText, // ✅ القيمة الحقيقية
                  color: serviceColor, // ✅ اللون الديناميكي
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لاختيار الأيقونة
  IconData closestStatusIcon(AppProvider provider) {
    if (provider.dueMaintenance.any((i) => i.status == 'OVERDUE')) return CupertinoIcons.exclamationmark_circle_fill;
    if (provider.dueMaintenance.any((i) => i.status == 'DUE_SOON')) return CupertinoIcons.wrench_fill;
    return CupertinoIcons.checkmark_shield_fill;
  }

  Widget _defaultIcon() => const Icon(CupertinoIcons.car_detailed, size: 30, color: AppColors.primary);

  Widget _buildInfoItem({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color == AppColors.primary ? Colors.white : color)),
        ],
      ),
    );
  }
}