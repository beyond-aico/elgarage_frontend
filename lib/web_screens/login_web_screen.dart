// lib/web_screens/login_web_screen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/providers/fleet_provider.dart';
import 'package:elgarage/providers/maintenance_provider.dart';
import 'package:elgarage/web_screens/register_web_screen.dart'; // ✅ استدعاء نسخة الويب من الريجستر
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/ui/textured_background.dart';

class LoginWebScreen extends StatefulWidget {
  const LoginWebScreen({super.key});

  @override
  State<LoginWebScreen> createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends State<LoginWebScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. تعريف الـ Providers المطلوبة
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final fleet = Provider.of<FleetProvider>(context, listen: false);
final maintenance = Provider.of<MaintenanceProvider>(context, listen: false); // ✅ السطر المضاف

    String identifier = _emailController.text.trim();

    // منطق معالجة رقم الهاتف
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

    // 2. محاولة تسجيل الدخول
    bool success = await auth.login(identifier, _passwordController.text);

    if (success && mounted) {
      debugPrint("🔑 Login Success! Synchronizing Context...");

      // 3. ✅ التعديل الجوهري: تمرير الـ fleetProvider كمعامل ثالث للمزامنة
      // هذا السطر يضمن أن بيانات السائق وسيارته ستنتقل فوراً لشاشة السائق
await app.syncUserContext(auth.user, auth, fleet, maintenance);
      debugPrint("🚀 UserContext Synced & Dashboard Ready.");

      // 4. الانتقال للواجهة الرئيسية بعد اكتمال المزامنة
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        debugPrint("🚀 UI Transferred to Home.");
      }
    } else if (mounted) {
      // عرض رسالة خطأ في حالة فشل تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "auth.error_invalid_auth".tr())),
      );
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // --- الجانب الأيسر: Branding Panel (Beyond AI Style) ---
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.textMain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 220),
                    const SizedBox(height: 30),
                    const Text(
                      "EL GARAGE TERMINAL",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "POWERED BY BEYOND AI SYSTEMS",
                      style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),

            // --- الجانب الأيمن: Login Form Workspace ---
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CONTROL PANEL ACCESS",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 1),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "PLEASE LOGIN TO HANDLE YOUR GARAGE",
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 50),

                          _buildWebInput(
                            controller: _emailController,
                            label: "USER EMAIL",
                            icon: Icons.lan_outlined,
                            validator: (v) => (v == null || !v.contains('@')) ? "Enter a valid email" : null,
                          ),
                          const SizedBox(height: 25),

                          _buildWebInput(
                            controller: _passwordController,
                            label: "SECURITY PASSWORD",
                            icon: Icons.vpn_key_outlined,
                            isObscure: true,
                            validator: (v) => (v == null || v.isEmpty) ? "Password required" : null,
                          ),
                          
                          const SizedBox(height: 40),

                          // زر الدخول المانجاوي
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 65,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.textMain,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 8,
                                  ),
                                  child: auth.isLoading
                                      ? const CupertinoActivityIndicator(color: AppColors.primary)
                                      : const Text(
                                          'INITIALIZE LOGIN',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
                                        ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("NEW COMMANDER?", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const RegisterWebScreen()),
                                  );
                                },
                                child: const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت الحقول الاحترافية للويب
  Widget _buildWebInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        prefixIcon: Icon(icon, color: AppColors.textMain, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      validator: validator,
    );
  }
}