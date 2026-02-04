import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.garage, 'My Garage'),
            _buildNavItem(1, Icons.vertical_shades_closed, 'My Car'),
            const SizedBox(width: 40), // مساحة للزر المركزي
            _buildNavItem(3, CupertinoIcons.cart_fill, 'SOS'),
            _buildNavItem(4, Icons.more, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? AppColors.primary : Colors.white54, 
              size: 24
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white54, 
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5
              ),
            ),
          ],
        ),
      ),
    );
  }
}