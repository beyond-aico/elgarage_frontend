import 'package:flutter/material.dart';
import 'dart:ui' as ui; 
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // 1. استدعاء مكتبة البروفايدر

import 'firebase_options.dart';

// Import Providers
import 'core/providers/cart_provider.dart'; // 2. استدعاء ملف السلة (تأكد من إنشائه)

// Import Pages
import 'features/pages/home_page.dart';
import 'features/pages/sos_page.dart';
import 'features/pages/maintenance_page.dart';
import 'features/pages/tires_batteries.dart';
import 'features/pages/services_page.dart';
import 'features/pages/care_page.dart';
import 'features/pages/my_garage_page.dart';
import 'features/pages/profile_page.dart';
// import 'features/pages/cart_page.dart'; // سنحتاجه لاحقاً

// Import Assistant
import 'core/ai/assistant_service.dart';
import 'features/assistant/assistant_fab.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MultiProvider( // 3. تغليف التطبيق بالبروفايدر
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const AutoMentorApp(),
      ),
    ),
  );
}

class AutoMentorApp extends StatefulWidget {
  const AutoMentorApp({super.key});

  @override
  State<AutoMentorApp> createState() => _AutoMentorAppState();
}

class _AutoMentorAppState extends State<AutoMentorApp> {
  VoiceAssistant? _assistant;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _assistant = VoiceAssistant(
      userId: 'user-123',
      sessionId: DateTime.now().toIso8601String(),
    );

    _assistant!.onRouteDetected = (route) {
      if (_navKey.currentState != null) {
        _navKey.currentState!.popUntil((r) => r.isFirst);
        if (route != '/') {
          _navKey.currentState!.pushNamed(route);
        }
      }
    };
  }

  @override
  void dispose() {
    _assistant?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Auto Mentor',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navKey,
          
          // Localization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            fontFamily: 'Tajawal',
          ),

          // Routes
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(),
            '/sos': (context) => const SosPage(),
            '/maintenance': (context) => const MaintenancePage(),
            '/tires': (context) => const TiresBatteriesPage(),
            '/services': (context) => const ServicesPage(),
            '/care': (context) => const CarePage(),
            '/garage': (context) => const MyGaragePage(),
            '/profile': (context) => const ProfilePage(),
            // '/cart': (context) => const CartPage(), // سنضيف هذا المسار لاحقاً
          },

          // Assistant Overlay
          builder: (context, child) {
            return Directionality(
              textDirection: context.locale.languageCode == 'ar' 
                  ? ui.TextDirection.rtl 
                  : ui.TextDirection.ltr,
              child: Stack(
                children: [
                  if (child != null) child,
                  if (_assistant != null)
                    Positioned(
                      bottom: 20.h,
                      left: context.locale.languageCode == 'ar' ? 20.w : null,
                      right: context.locale.languageCode == 'en' ? 20.w : null,
                      child: AssistantFab(
                        va: _assistant!,
                        navKey: _navKey,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}