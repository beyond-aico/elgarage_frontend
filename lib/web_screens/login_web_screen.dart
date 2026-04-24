// lib/web_screens/login_web_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart'; // [cite: 31]
import '../providers/auth_provider.dart'; // [cite: 303]
import '../providers/app_provider.dart'; // [cite: 251]
import '../providers/fleet_provider.dart'; // [cite: 353]
import '../providers/maintenance_provider.dart'; // [cite: 381]
import '../core/app_ui/textured_background.dart'; // [cite: 240]

class LoginWebScreen extends StatefulWidget {
  const LoginWebScreen({super.key});

  @override
  State<LoginWebScreen> createState() => _LoginWebScreenState();
}

class _LoginWebScreenState extends State<LoginWebScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final fleet = Provider.of<FleetProvider>(context, listen: false);
    final maintenance = Provider.of<MaintenanceProvider>(context, listen: false);

    // استخدام الـ logic الموحد لتسجيل الدخول [cite: 327, 664]
    bool success = await auth.login(_identifierController.text.trim(), _passwordController.text);
    
    if (success && mounted) {
      // مزامنة البيانات فوراً بناءً على الـ Role [cite: 259, 666]
      await app.syncUserContext(auth.user, auth, fleet, maintenance);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TexturedBackground( // 
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.textMain.withAlpha(240), // [cite: 34]
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(10)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 30),
                  const Text("SYSTEM ACCESS", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14)), // [cite: 31]
                  const SizedBox(height: 40),
                  _buildInput("IDENTIFIER", Icons.person_outline, _identifierController),
                  const SizedBox(height: 20),
                  _buildInput("PASSWORD", Icons.lock_outline, _passwordController, isObscure: true),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), // [cite: 31]
                      onPressed: _handleLogin,
                      child: const Text("INITIALIZE SESSION", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 1)), // [cite: 32]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController controller, {bool isObscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18), // [cite: 31]
        filled: true,
        fillColor: Colors.white.withAlpha(5),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(10)), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(10)), // [cite: 31]
      ),
    );
  }
}