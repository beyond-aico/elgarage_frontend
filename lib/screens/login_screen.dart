import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/ui/textured_background.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = Provider.of<AuthProvider>(context, listen: false);
  final app = Provider.of<AppProvider>(context, listen: false);
  await app.syncUserContext(auth.user);
  bool success = await auth.login(
    _emailController.text.trim(), 
    _passwordController.text
  );

  if (success && mounted) {
    // 1. جلب بيانات السيارات
    await app.fetchMyCars();

    // ✅ التعديل الجوهري: لا تستخدم Navigator هنا!
    // بمجرد نجاح اللوجن، ستقوم notifyListeners() بتنبيه InitialRouter 
    // الموجود في main.dart ليقوم بتحويلك للشاشة الصحيحة تلقائياً. [cite: 1, 13]
    print("🚀 LOGIN_SUCCESS: InitialRouter will handle redirection.");
  }
}


  @override
  Widget build(BuildContext context) {
    final authStatus = Provider.of<AuthProvider>(context);
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/logo.png', height: 180,
                            errorBuilder: (c,e,s) => const Icon(Icons.garage, color: Colors.white, size: 50)),
                          const SizedBox(height: 10),
                          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                        ],
                      ),
                      const Text('PLEASE LOGIN TO HANDLE YOUR GARAGE', style: TextStyle(letterSpacing: 2, color: AppColors.textSub)),
                      const SizedBox(height: 50),

                      // تم إزالة الـ Role Toggle بناءً على طلبك

                      _buildIndustrialInput(
                        controller: _emailController, 
                        label: "EMAIL", 
                        icon: Icons.lan_outlined
                      ),
                      const SizedBox(height: 15),
                      _buildIndustrialInput(
                        controller: _passwordController, 
                        label: "PASSWORD", 
                        icon: Icons.vpn_key_outlined, 
                        isObscure: true
                      ),
                      const SizedBox(height: 30),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: authStatus.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textMain,
                            // ✅ تعديل رقم 1: جعل الحواف انسيابية (Rounded)
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                         child: const Text('LOGIN', 
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                       const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                               Navigator.of(context).push(
                                 MaterialPageRoute(builder: (context) => const RegisterScreen()),
                               );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // ✅ تعديل رقم 1 مكمل: جعل حقول الإدخال انسيابية
  Widget _buildIndustrialInput({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isObscure = false
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSub, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          borderRadius: BorderRadius.circular(15), // حواف انسيابية
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(15), // حواف انسيابية
        ),
      ),
    );
  }
}