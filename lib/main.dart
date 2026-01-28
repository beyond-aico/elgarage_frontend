import 'package:elgarage/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart'; // مكتبة فايربيز

void main() async {
  // 1. ضمان تهيئة الـ Widgets قبل أي كود Async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. تشغيل فايربيز (لازم تكون حملت ملف google-services.json)
  await Firebase.initializeApp();

  runApp(const ElGarageApp());
}

class ElGarageApp extends StatelessWidget {
  const ElGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'El Garage',
        debugShowCheckedModeBanner: false,
        
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.cairoTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
          ),
          useMaterial3: true,
        ),
        
        home: const LoginScreen(),
      ),
    );
  }
}