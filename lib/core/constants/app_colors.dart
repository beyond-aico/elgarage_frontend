import 'package:flutter/material.dart';


class AppColors {
  // --- الألوان الرئيسية (Ismaily Spirit Colors) ---
  static const Color primary = Color(0xFFFFAC43);      // المانجاوي
  static const Color secondary = Color(0xFF101010);    // الأسفلتي
  static const Color accent = Color(0xFFFFAC43);       

  // --- ألوان الخلفيات ---
  static const Color background = Color(0xFFFAF9F6);   
  static const Color cardColor = Colors.white;         
  static const Color surface = Color(0xFFFAF9F6);      // أضفت دي عشان لو فيه ملف محتاجها

  // --- النصوص (ثبتنا المسميات اللي بتعمل Errors) ---
  static const Color textPrimary = Color(0xFF212121);  
  static const Color textSecondary = Color(0xFF757575); 
  
  // ✅ الروابط اللي هتحل كل الـ Errors اللي ظهرت عندك:
  static const Color textMain = textPrimary;    // حل مشكلة Undefined getter 'textMain'
  static const Color textSub = textSecondary;   // حل مشكلة Undefined getter 'textSub'
  static const Color textOnDark = Colors.white;

  // --- ألوان الحالات (Functional Colors) ---
  static const Color success = Color(0xFF2E7D32);      
  static const Color error = Color(0xFFD32F2F);        
  static const Color warning = Color(0xFFFFA000);      
  static const Color danger = error;            // ✅ حل مشكلة Undefined getter 'danger'

  // --- إضافات تقنية لشريط التحذير ---
  static const Color tapeBlack = Color(0xFF101010); 
}