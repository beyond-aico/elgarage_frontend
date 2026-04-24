// lib/core/app_ui/textured_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TexturedBackground extends StatelessWidget {
  final Widget child;
  const TexturedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // ⚠️ تم إزالة الـ Scaffold واستبداله بـ Container لضمان التوافق مع الويب والموبايل
    return Container(
      color: const Color(0xFFF9F9F9), // الأوف وايت البوهيمي اللي اتفقتوا عليه
      child: Stack(
        children: [
          // 1. طبقة الرسم (الخطوط و علامات X)
          Positioned.fill(
            child: RepaintBoundary( // تحسين الأداء أثناء الـ Scroll
              child: CustomPaint(
                painter: EnhancedBohemianPainter(),
              ),
            ),
          ),
          
          // 2. طبقة تركيز الضوء (Vignette) لزيادة العمق
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2, // زيادة القطر قليلاً لتناسب الشاشات الكبيرة
                  colors: [
                    Colors.transparent,
                    AppColors.textMain.withAlpha(05), // لمسة ظل خفيفة جداً
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // 3. المحتوى (الصفحة)
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
      ..color = Colors.black.withAlpha(08) // درجة شفافة جداً للرسم
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final random = Random(101); // لضمان ثبات شكل الخلفية في كل مرة

    // رسم الخطوط الانسيابية (Flows) التي تميز روح Beyond AI
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

    // رسم علامات X التقنية لإعطاء طابع الـ Blueprint
    for(int i = 0; i < 15; i++) { // زيادة العدد قليلاً للويب
      double dx = random.nextDouble() * size.width;
      double dy = random.nextDouble() * size.height;
      canvas.drawLine(Offset(dx - 5, dy - 5), Offset(dx + 5, dy + 5), paint);
      canvas.drawLine(Offset(dx + 5, dy - 5), Offset(dx - 5, dy + 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}