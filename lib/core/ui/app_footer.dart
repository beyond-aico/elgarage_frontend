import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.textMain, 
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // استخدام Expanded لزيادة مساحة الضغط لكل عنصر
            Expanded(child: _buildNavItem(0, Icons.garage, 'My Garage')),
            Expanded(child: _buildNavItem(1, Icons.directions_car_filled_rounded, 'My Car')),
            
            // مساحة فارغة للزر المركزي (FAB)
            const SizedBox(width: 48), 
            
            Expanded(child: _buildNavItem(3, Icons.sos_sharp, 'SOS')),
            Expanded(child: _buildNavItem(4, Icons.grid_view_rounded, 'More')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // يجعل المنطقة المحيطة بالأيقونة قابلة للنقر
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.white54,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white54,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.normal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}