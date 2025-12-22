import 'package:flutter/material.dart';

class AppColors {
  // === Light Tech Theme Identity ===
  static const Color background = Color(0xFFFAFAFA); // أبيض ثلجي للخلفية
  static const Color surface = Colors.white;         // أبيض ناصع للكروت
  static const Color primary = Color(0xFF1F1F1F);    // رمادي غامق جداً (لون البراند الأساسي)
  static const Color accent = Color(0xFF2563EB);     // أزرق حيوي للأيقونات والزرار
  
  // النصوص
  static const Color textPrimary = Color(0xFF1F1F1F); // أسود/رمادي للكتابة
  static const Color textSecondary = Color(0xFF64748B); // رمادي متوسط للتفاصيل
  
  // التدرجات (تم تعديلها لتناسب الثيم الفاتح)
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)], // تدرج رمادي فاتح جداً
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // التوافق مع الكود القديم
  static const Color textDark = textPrimary;
  static const Color textLight = Colors.white; // للنصوص اللي فوق خلفيات غامقة
  static const Color iconColor = primary;
}