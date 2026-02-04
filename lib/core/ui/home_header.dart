import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String userName;
  final String statsText;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final IconData actionIcon;
  final Widget rightIcon;

  const HomeHeader({
    super.key,
    required this.title,
    required this.userName,
    required this.statsText,
    required this.actionLabel,
    required this.onActionPressed,
    this.actionIcon = Icons.add_circle_outline,
    this.rightIcon = const Icon(Icons.garage_rounded, color: Colors.white, size: 40),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية المقوسة المستخرجة من HomeScreen
        ClipPath(
          clipper: HeroClipper(),
          child: Container(
            height: 280,
            width: double.infinity,
            color: AppColors.textMain, 
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        userName, 
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: AppColors.primary, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            statsText, 
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      rightIcon,
                      const SizedBox(height: 15),
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: Icon(actionIcon, size: 20),
                label: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// الكليبر المسؤول عن التقويسة
class HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}