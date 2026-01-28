import 'package:flutter/material.dart';

class AppColors {
  // === 🏎️ Modern Sport Theme (روح رياضية وفخامة) ===
  
  // 1. اللون الأساسي: أسود فحمي مائل للأزرق (فخم جداً للهيدر والفوتر)
  static const Color primary = Color(0xFF1B1F23); 
  
  // 2. لون الروح (Accent): برتقالي ناري (للأزرار المهمة، الأيقونات النشطة)
  // ده اللون اللي "هيحيي" التطبيق بجد
  static const Color accent = Color(0xFFFF6B00); 

  // 3. لون ثانوي: رمادي معدني (للأيقونات الفرعية والتفاصيل)
  static const Color secondary = Color(0xFF546E7A);

  // --- الخلفيات والكروت ---
  static const Color background = Color(0xFFF4F6F8); // رمادي فاتح جداً (ثلجي)
  static const Color surface = Colors.white;         // أبيض ناصع للكروت
  
  // --- النصوص ---
  static const Color textPrimary = Color(0xFF263238); // رصاصي غامق (أشيك من الأسود الصريح)
  static const Color textSecondary = Color(0xFF78909C); // رصاصي فاتح مريح

  // --- التدرجات (عشان لو حبيت تعمل زرار شكله 3D) ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B1F23), Color(0xFF37474F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFF6B00)], // تدرج برتقالي حيوي
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === Compatibility (عشان الكود القديم يشتغل زي الفل) ===
  static const Color cardColor = surface;
  
  // ألوان الحالات (Functional)
  static const Color success = Color(0xFF00C853);      // أخضر نيون (Android Green)
  static const Color error = Color(0xFFD50000);        // أحمر صريح
  static const Color warning = Color(0xFFFFD600);      // أصفر
}