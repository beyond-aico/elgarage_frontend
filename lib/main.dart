// --- FILE: lib/main.dart ---

import 'package:elgarage/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'core/ui/main_layout.dart'; 
import 'screens/fleet/fleet_dashboard.dart'; 
import 'screens/driver/driver_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ELGarage());
}

class ELGarage extends StatelessWidget {
  const ELGarage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'ELGarage',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto', 
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.warning,
            surface: AppColors.cardColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          useMaterial3: true,
        ),
        // ✅ إضافة الـ Builder لحماية التصميم من تكبير الخطوط المفاجئ
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

// ✅ تحويل الـ InitialRouter ليكون StatefulWidget لفحص الـ Session
// ✅ التعديل الاحترافي للـ InitialRouter في ملف main.dart
class InitialRouter extends StatefulWidget {
  const InitialRouter({super.key});

  @override
  State<InitialRouter> createState() => _InitialRouterState();
}
// داخل main.dart الجزء الخاص بـ InitialRouter

class _InitialRouterState extends State<InitialRouter> {
  late Future<bool> _authFuture;

@override
void initState() {
  super.initState();
  // ✅ فحص الجلسة وإذا نجحت، قم بمزامنة البيانات فوراً
  _authFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin().then((success) {
    if (success && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AppProvider>(context, listen: false).syncUserContext(auth.user);
    }
    return success;
  });
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        // أثناء الفحص، اظهر شاشة لودينج (Splash)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.amber)));
        }

        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isAuthenticated) return const LoginScreen();

           final role = auth.user?.role;
    
    // 🚨 المشكلة كانت هنا: غيرنا FLEET_MANAGER لـ ACCOUNT_MANAGER
    if (role == "ACCOUNT_MANAGER" || role == "ADMIN") {
      return const FleetDashboard(); 
    } 
    
    if (role == "DRIVER") {
      return const DriverScreen();
    }

    return const MainLayout(); // للمستخدمين العاديين
  },
);
      },
    );
  }
}