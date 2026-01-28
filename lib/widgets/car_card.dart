import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/car_model.dart'; // تأكد إن ده المسار الصح

class CarCard extends StatelessWidget {
  final Car car; // غيرنا من CarModel لـ Car
  final bool isSelected;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.car,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Car Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                image: car.imageUrl != null && car.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(car.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: car.imageUrl == null || car.imageUrl!.isEmpty
                  ? Icon(Icons.directions_car, size: 40, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 15),

            // Car Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.make} ${car.model}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${car.year} • ${car.color ?? "No Color"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      car.licensePlate ?? 'No Plate',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}