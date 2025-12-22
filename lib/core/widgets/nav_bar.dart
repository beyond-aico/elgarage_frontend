import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      title: Row(
        children: [
          // زر الرئيسية (Logo placeholder)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_rounded, color: AppColors.primary),
          ),
          const Spacer(),
          // الأزرار الجانبية
          _NavBarIcon(icon: Icons.language, onTap: () {}), // اللغة
          _NavBarIcon(icon: Icons.person_outline, onTap: () {}), // بروفايل
          _NavBarIcon(icon: Icons.info_outline, onTap: () {}), // عن التطبيق
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.textDark),
      splashRadius: 24,
    );
  }
}