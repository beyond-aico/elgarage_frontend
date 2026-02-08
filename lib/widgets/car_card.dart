// --- FILE: lib/widgets/car_card.dart ---

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ✅ تحديد ارتفاع وعرض ثابت للكارت لمنع مشاكل الـ Infinity Constraints
        width: 320,
        height: 300, 
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withAlpha(05), 
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. قسم الصورة
            SizedBox(
              height: 160, // ارتفاع ثابت للصورة
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                        ? Image.network(
                            car.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textMain.withAlpha(8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        car.year.toString(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
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
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                    const Divider(color: Colors.white10, height: 1),

                    Row(
                      children: [
                        const Icon(CupertinoIcons.gauge, size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                     // داخل car_card.dart سطر 771 تقريباً
Text(
  '${car.currentKm} KM', 
  style: const TextStyle(
    color: AppColors.primary, // ✅ تغيير اللون للبرتقالي ليكون واضحاً جداً
    fontSize: 14,             // تكبير الخط قليلاً
    fontWeight: FontWeight.w900,
  ),
),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withAlpha(5)),
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

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/car_card.jpg',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.textMain,
        child: const Center(child: Icon(Icons.directions_car, color: Colors.white24, size: 50)),
      ),
    );
  }
}