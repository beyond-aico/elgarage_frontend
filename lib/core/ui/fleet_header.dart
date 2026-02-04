import 'package:elgarage/core/ui/home_header.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FleetHeader extends StatelessWidget {
  final String userName;
  final String points;
  final VoidCallback onGrowFleet;

  const FleetHeader({
    super.key,
    required this.userName,
    required this.points,
    required this.onGrowFleet,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية المقوسة - تم تقليل الارتفاع ليلتحم مع الزرار تماماً
        ClipPath(
          clipper: HeroClipper(),
          child: Container(
            height: 275, // هذا الارتفاع يضمن انتهاء اللون الأسود عند الزرار
            width: double.infinity,
            color: AppColors.textMain,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        // قسم النقاط
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(color: AppColors.primary, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: AppColors.primary, size: 14),
                              const SizedBox(width: 5),
                              Text('$points FLEET POINTS', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset('assets/images/logo.png', height: 80, 
                          errorBuilder: (c, e, s) => const Icon(Icons.admin_panel_settings, color: Colors.white, size: 50)),
                        const SizedBox(height: 10),
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // زر التوسع - الآن هو في نهاية القوس تماماً
                ElevatedButton.icon(
                  onPressed: onGrowFleet,
                  icon: const Icon(Icons.add_business_outlined, size: 20),
                  label: const Text('GROW MY FLEET', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}