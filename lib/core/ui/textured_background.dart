import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TexturedBackground extends StatelessWidget {
  final Widget child;
  const TexturedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // أوف وايت بوهيمي
      body: Stack(
        children: [
          // 1. طبقة الرسوم الفنية (Bohemian Painter)
          Positioned.fill(
            child: CustomPaint(
              painter: EnhancedBohemianPainter(),
            ),
          ),
          
          // 2. طبقة تركيز الضوء (Vignette)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    AppColors.textMain.withAlpha(03),
                  ],
                  stops: const [0.6, 1.0]
                ),
              ),
            ),
          ),
          
          child,
        ],
      ),
    );
  }
}

class EnhancedBohemianPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final random = Random(101); // لضمان ثبات الشكل

    // رسم الخطوط الانسيابية (Flows)
    for (int i = 0; i < 8; i++) {
      final path = Path();
      path.moveTo(random.nextDouble() * size.width, random.nextDouble() * size.height);
      path.cubicTo(
        random.nextDouble() * size.width, random.nextDouble() * size.height,
        random.nextDouble() * size.width * 1.2, random.nextDouble() * size.height * 1.2,
        random.nextDouble() * size.width, random.nextDouble() * size.height,
      );
      canvas.drawPath(path, paint);
    }

    // رسم علامات X التقنية
    for(int i=0; i<12; i++) {
      double dx = random.nextDouble() * size.width;
      double dy = random.nextDouble() * size.height;
       canvas.drawLine(Offset(dx-5, dy-5), Offset(dx+5, dy+5), paint);
       canvas.drawLine(Offset(dx+5, dy-5), Offset(dx-5, dy+5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}