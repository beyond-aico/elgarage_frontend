import 'package:easy_localization/easy_localization.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/providers/fleet_provider.dart';
//import 'package:elgarage/screens/fleet/driver_qr_scanner.dart';
import 'package:elgarage/app_screens/auth/phone_login_screen.dart'; // تأكد من المسار الصحيح
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_ui/textured_background.dart';
import '../../providers/maintenance_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = Provider.of<AuthProvider>(context, listen: false);
  final app = Provider.of<AppProvider>(context, listen: false);
  final fleet = Provider.of<FleetProvider>(context, listen: false);
  final maintenance = Provider.of<MaintenanceProvider>(context, listen: false);
  String identifier = _identifierController.text.trim();

  // معالجة رقم الهاتف
  if (RegExp(r'^[0-9]+$').hasMatch(identifier)) {
    if (identifier.startsWith('0')) {
      identifier = '+20${identifier.substring(1)}';
    } else if (!identifier.startsWith('+') && !identifier.startsWith('20')) {
      identifier = '+20$identifier';
    } else if (identifier.startsWith('20')) {
      identifier = '+$identifier';
    }
  }

  debugPrint("🔑 Login Attempt with Identifier: $identifier");

  bool success = await auth.login(identifier, _passwordController.text);

  if (success && mounted) {
  // مزامنة البيانات الأساسية
  await app.syncUserContext(auth.user, auth, fleet, maintenance);

  if (mounted) {
    // 🎯 توجيه السائق للسكانر إذا لم يسبق له ربط سيارة في هذه الجلسة
    if (auth.user?.role.toUpperCase() == "DRIVER" && fleet.authenticatedCar == null) {
      Navigator.pushReplacementNamed(context, '/driver-qr-scanner');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
 else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.errorMessage ?? "Error during login")),
    );
  }
}

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد اللغة الحالية لعرض الزر المناسب
    bool isArabic = context.locale.languageCode == 'ar';

   return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // ✅ AppBar يحتوي على زر تغيير اللغة
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextButton.icon(
                onPressed: () {
                  if (isArabic) {
                    context.setLocale(const Locale('en'));
                  } else {
                    context.setLocale(const Locale('ar'));
                  }
                },
                icon: const Icon(Icons.language, color: AppColors.textMain, size: 18),
                label: Text(
                  isArabic ? "English" : "العربية",
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
            child: Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.garage,
                          color: AppColors.textMain,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'auth.welcome_title'.tr(),
                        style: const TextStyle(
                          letterSpacing: 2,
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildIndustrialInput(
                        controller: _identifierController,
                        label: 'auth.identifier_label'.tr(),
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildIndustrialInput(
                        controller: _passwordController,
                        label: 'auth.password_label'.tr(),
                        icon: Icons.lock_outline,
                        isObscure: true,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textMain,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(color: AppColors.primary)
                              : Text(
                                  'auth.login_btn'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('auth.no_account'.tr(), style: const TextStyle(color: AppColors.textMain)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // زر الدخول عبر الهاتف (Quick Phone Login)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                        ),
                        icon: const Icon(Icons.phone_android, color: AppColors.textMain),
                        label: Text(
                          "auth.quick_phone_login".tr(),
                          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.textMain, width: 1.5),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      /*
                      const SizedBox(height: 12),

                      // ✅ زر مسح الباركود الجديد (LOGIN VIA VEHICLE QR)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DriverQRScanner()),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                        label: const Text(
                          "LOGIN VIA VEHICLE QR",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white10, width: 1.5),
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),*/
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndustrialInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSub, fontSize: 11),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withAlpha(10)),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}