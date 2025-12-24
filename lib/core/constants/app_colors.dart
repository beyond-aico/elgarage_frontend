import 'package:flutter/material.dart';

class AppColors {
  // --- الألوان الرئيسية (من وحي Beyond AI) ---
  // استبدل الأكواد دي بألوان الموقع بتاعكم
  static const Color primary = Color(0xFF2563EB);      // اللون الأساسي (أزرق مثلاً)
  static const Color secondary = Color(0xFF1E293B);    // لون ثانوي (غامق للهيدر مثلاً)
  static const Color accent = Color(0xFFF59E0B);       // لون مميز للأزرار (زي Add to Cart)

  // --- ألوان الخلفيات والنصوص ---
  static const Color background = Color(0xFFF8FAFC);   // خلفية التطبيق (فاتحة مريحة للعين)
  static const Color cardColor = Colors.white;         // خلفية الكروت (العربيات، المنتجات)
  
  static const Color textPrimary = Color(0xFF0F172A);  // للنصوص العناوين
  static const Color textSecondary = Color(0xFF64748B); // للنصوص الفرعية (زي الكيلومتر)

  // --- ألوان الحالات (Functional Colors) ---
  static const Color success = Color(0xFF10B981);      // تم بنجاح
  static const Color error = Color(0xFFEF4444);        // خطأ أو خطر
  static const Color warning = Color(0xFFF59E0B);      // تنبيه صيانة
}