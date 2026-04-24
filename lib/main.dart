import 'package:elgarage/app_screens/fleet/driver_qr_scanner.dart';
import 'package:elgarage/app_screens/fleet/driver_screen.dart'; // ✅ إضافة الاستيراد
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:elgarage/app_screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/fleet_provider.dart'; 
import 'core/app_ui/main_layout.dart'; 
import 'app_screens/fleet/fleet_dashboard.dart'; 
import 'firebase_options.dart';
import 'core/app_ui/responsive_layout.dart';
import 'web_screens/login_web_screen.dart';
import 'web_screens/fleet_dashboard_web.dart';
import 'web_screens/home_web_screen.dart';
import 'web_screens/main_web_screen.dart'; 
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const ELGarage(),
    ),
  );
}

class ELGarage extends StatelessWidget {
  const ELGarage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => FleetProvider()), 
      ],
      child: MaterialApp(
        title: 'ELGarage',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: context.locale.languageCode == 'ar' ? 'Cairo' : 'Roboto',
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.warning,
            surface: AppColors.cardColor,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CrossFadePageTransitionsBuilder(),
              TargetPlatform.iOS: CrossFadePageTransitionsBuilder(),
            },
          ),
          useMaterial3: true,
        ),
        // ✅ إضافة المسارات الناقصة لحل مشكلة الـ RouteSettings Error
        routes: {
          '/login': (context) => const ResponsiveLayout(
                mobileScreen: LoginScreen(),
                webScreen: LoginWebScreen(),
              ),
          '/home': (context) => const MainLayout(),
          '/driver-qr-scanner': (context) => const DriverQRScanner(),
          '/driver-screen': (context) => const DriverScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.2)),
            ),
            child: child!,
          );
        },
        home: const InitialRouter(),
      ),
    );
  }
}

class CrossFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const CrossFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class InitialRouter extends StatefulWidget {
  const InitialRouter({super.key});
  @override
  State<InitialRouter> createState() => _InitialRouterState();
}

class _InitialRouterState extends State<InitialRouter> {
  late Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _handleInitialData();
  }

  Future<bool> _handleInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final fleet = Provider.of<FleetProvider>(context, listen: false);
    final maintenance = Provider.of<MaintenanceProvider>(context, listen: false);

    bool success = await auth.tryAutoLogin();
    if (success && mounted && auth.user != null) {
      await app.syncUserContext(auth.user, auth, fleet, maintenance); 
    }
    return success; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.amber)),
          );
        }

        // ✅ استخدام Consumer2 لمراقبة حالة الـ Auth والـ Fleet معاً
        return Consumer2<AuthProvider, FleetProvider>(
          builder: (context, auth, fleet, _) {
            if (!auth.isAuthenticated || auth.user == null) {
              if (kIsWeb) {
                return const MainWebScreen();
              } else {
                return const LoginScreen();
              }
            }

            final String role = auth.user!.role.toUpperCase();
            debugPrint("🎯 User Role Detected: $role");

            if (role == "ACCOUNT_MANAGER" || role == "ADMIN") {
              return const ResponsiveLayout(
                mobileScreen: FleetDashboard(),
                webScreen: FleetDashboardWeb(),
              );
            } 
            
            // 🎯 منطق السائق المعدل:
            else if (role == "DRIVER") {
              // لو السواق لسه ممعاهوش عربية مربوطة في السيشن دي -> واديه للسكانر
              if (fleet.authenticatedCar == null) {
                return const DriverQRScanner();
              } else {
                // لو مربوط بعربية (سواء بعد السكان أو بعد الـ AutoLogin) -> واديه للشاشة بتاعته
                return const DriverScreen();
              }
            }

            return const ResponsiveLayout(
              mobileScreen: MainLayout(),
              webScreen: HomeWebScreen(),
            );
          },
        );
      },
    );
  }
}