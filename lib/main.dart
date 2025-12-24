import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const AutoMentorApp());
}

class AutoMentorApp extends StatelessWidget {
  const AutoMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // هنا بنعرف التطبيق إن فيه "مخ" اسمه AppProvider لازم يسمع كلامه
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Auto Mentor',
        debugShowCheckedModeBanner: false,
        
        // إعدادات الثيم والألوان والخطوط
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          
          // إعداد الخطوط (Cairo للعربي والإنجليزي شكله شيك)
          textTheme: GoogleFonts.cairoTextTheme(
            Theme.of(context).textTheme,
          ),
          
          // ألوان التطبيق العامة
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          
          useMaterial3: true,
        ),
        
        // أول شاشة هتفتح هي الـ Layout اللي شايل الفوتر
        home: const MainLayout(),
      ),
    );
  }
}