import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/screens/driver/driver_screen.dart';
import 'package:elgarage/screens/fleet/fleet_dashboard.dart';
import 'package:elgarage/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/textured_background.dart'; // الملف الذي يحتوي على الرسام البوهيمي
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isFleetMode = false; // التبديل بين عادي وأسطول
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

// --- داخل ملف lib/screens/login_screen.dart ---

Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    
    // 1. تنفيذ محاولة تسجيل الدخول
    bool success = await auth.login(
      _emailController.text.trim(), 
      _passwordController.text
    );

    if (success && mounted) {
      // 2. جلب بيانات السيارات فوراً لمعرفة حالة المستخدم
      await app.fetchMyCars();

      final role = auth.user?.role;
      print("🚀 LOGIN_SYSTEM: Access Granted for Role: $role");

      // 3. التوجيه الديناميكي بناءً على الصلاحيات القادمة من الباك إند
      if (role == "FLEET_MANAGER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FleetDashboard()));
      } else if (role == "DRIVER") {
        // إذا كان سواق، نحدد سيارته تلقائياً ليراها في شاشته
        if (app.myCars.isNotEmpty) {
          app.setSelectedCar(app.myCars.first);
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverScreen()));
      } else {
        // المستخدم العادي يذهب للجراج والماركت
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final authStatus = Provider.of<AuthProvider>(context);
    return TexturedBackground( // تطبيق الخلفية البوهيمية المستخرجة
      child: Scaffold(
        backgroundColor: Colors.transparent, // لجعل الخلفية تظهر
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
        // اليمين: اللوجو + الكارت
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset('assets/images/logo.png', height: 180,
                                errorBuilder: (c,e,s) => const Icon(Icons.garage, color: Colors.white, size: 50)),
                              const SizedBox(height: 10),
                              // أيقونة الكارت (Opposite to Points)
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                            ],
                          ),
                                                const Text('CAR SERVICE', style: TextStyle(letterSpacing: 2, color: AppColors.textSub)),
const SizedBox(height: 50),

                  // --- مفتاح التبديل (Role Toggle) لراحة المستخدم ---
                  _buildRoleToggle(),

                  const SizedBox(height: 30),

                  // --- حقول الإدخال ---
                  _buildIndustrialInput(
                    controller: _emailController, 
                    label: "TERMINAL_ID / EMAIL", 
                    icon: Icons.lan_outlined
                  ),
                  const SizedBox(height: 15),
                  _buildIndustrialInput(
                    controller: _passwordController, 
                    label: "ACCESS_KEY", 
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
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // زوايا حادة
                          ),
                         child: Text('LOGIN', 
                            style: TextStyle(color: isFleetMode ? Colors.black : AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                       const SizedBox(height: 24),

                      // --- Register Link ---
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
                            child: Text(
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

// ويدجت التبديل بين الأنواع
  Widget _buildRoleToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Row(
        children: [
          _toggleBtn("INDIVIDUAL", !isFleetMode, () => setState(() => isFleetMode = false)),
          _toggleBtn("FLEET OWNER", isFleetMode, () => setState(() => isFleetMode = true)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          color: active ? AppColors.secondary : Colors.white,
          child: Center(
            child: Text(label, 
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.secondary, 
                fontWeight: FontWeight.w900, 
                fontSize: 11
              )
            ),
          ),
        ),
      ),
    );
  }

  // تصميم حقل الإدخال الصناعي
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
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}