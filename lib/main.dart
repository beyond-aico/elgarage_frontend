// --- FILE: lib/main.dart ---

import 'package:elgarage/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_layout.dart'; // للمستخدم العادي
import 'screens/fleet/fleet_dashboard.dart'; // لمدير الأسطول
import 'screens/driver/driver_screen.dart'; // للسائق

void main() async {
  // 1. تهيئة الـ Widgets وضمان عمل الكود الـ Async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. تشغيل فايربيز (تأكد من وجود ملفات الإعداد في مجلد android/ios)
  await Firebase.initializeApp();

  runApp(const AutoMentorApp());
}

class AutoMentorApp extends StatelessWidget {
  const AutoMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Auto Mentor Fleet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // --- الهوية الصناعية الجديدة (Asphalt & Mango) ---
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto', // الخط التقني المعتمد
          
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.warning,
            surface: AppColors.cardColor,
          ),
          
          // ستايل الأزرار الموحد (Industrial Style)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          useMaterial3: true,
        ),
        
        // --- منطق التوجيه الذكي عند فتح التطبيق ---
        home: const InitialRouter(), 
      ),
    );
  }
}

// --- الملف: lib/main.dart ---
// ... الاستيرادات ...

class InitialRouter extends StatelessWidget {
  const InitialRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // 1. إذا لم يكن مسجلاً، اذهب للوج إن
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // 2. التوجيه الصارم بناءً على الدور (Role)
    final role = auth.user?.role;
    print("🚦 Current User Role: $role");

    if (role == "FLEET_MANAGER") {
      return const FleetDashboard(); // واجهة المدير فقط
    } else if (role == "DRIVER") {
      return const DriverScreen(); // واجهة السائق فقط
    } else {
      return const MainLayout(); // واجهة المستخدم العادي (الماركت والجراج)
    }
  }
}