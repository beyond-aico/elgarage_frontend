import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../data/models/car_model.dart'; // الموديل الجديد (Car)

class CarCard extends StatelessWidget {
  final Car car; // استخدام موديل Car الحقيقي
  final VoidCallback? onTap;
  final bool isSelected;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // دمج منطق اللون من الكود الأول مع الهيكل من الثاني
          color: isSelected ? AppColors.primary.withAlpha(5) : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade100, 
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. صورة العربية (Full Width Top) - منطق الكود الأول في الصور
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                  ? Image.network(
                      car.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // حماية من الأخطاء في الصور القادمة من السيرفر
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // 2. بيانات العربية (Padding & Info)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // اسم وماركة العربية
                      Text(
                        '${car.make} ${car.model}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // سنة الصنع
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.year.toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // تفاصيل إضافية (اللون - من الكود الأول)
                  Text(
                    'Color: ${car.color ?? "Standard"}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // العداد الحالي
                      const Icon(CupertinoIcons.speedometer, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${car.currentKm} KM',
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      
                      // رقم اللوحة (من الكود الأول)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: Text(
                          car.licensePlate ?? 'No Plate',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجتPlaceholder في حالة عدم وجود صورة
  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[100],
      child: Icon(CupertinoIcons.car_detailed, size: 50, color: Colors.grey[300]),
    );
  }
}