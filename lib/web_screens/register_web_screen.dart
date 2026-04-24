// lib/web_screens/register_web_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/app_ui/main_layout.dart';
import '../core/app_ui/textured_background.dart';

class RegisterWebScreen extends StatefulWidget {
  const RegisterWebScreen({super.key});

  @override
  State<RegisterWebScreen> createState() => _RegisterWebScreenState();
}

class _RegisterWebScreenState extends State<RegisterWebScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // --- الجانب الأيسر: Branding & Identity ---
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.textMain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 200),
                    const SizedBox(height: 30),
                    const Text(
                      "JOIN THE FLEET",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "START YOUR JOURNEY WITH AUTO MENTOR",
                      style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 2),
                    ),
                    const SizedBox(height: 40),
                    // زر الرجوع للوجن بشكل شيك
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.primary),
                      label: const Text("BACK TO LOGIN", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- الجانب الأيمن: Registration Form ---
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  width: 550,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CREATE NEW ACCOUNT",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 1),
                          ),
                          const SizedBox(height: 10),
                          const Text("Complete the system deployment credentials", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 40),

                          _buildWebField(
                            controller: _nameController,
                            label: 'FULL NAME',
                            icon: CupertinoIcons.person_alt,
                            validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildWebField(
                                  controller: _emailController,
                                  label: 'EMAIL ADDRESS',
                                  icon: CupertinoIcons.mail_solid,
                                  type: TextInputType.emailAddress,
                                  validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildWebField(
                                  controller: _phoneController,
                                  label: 'PHONE NUMBER',
                                  icon: CupertinoIcons.phone_fill,
                                  type: TextInputType.phone,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Phone required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildWebField(
                            controller: _passwordController,
                            label: 'SECURE PASSWORD',
                            icon: CupertinoIcons.lock_fill,
                            isPassword: true,
                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 20),

                          _buildWebField(
                            controller: _confirmPasswordController,
                            label: 'CONFIRM PASSWORD',
                            icon: CupertinoIcons.lock_shield_fill,
                            isPassword: true,
                            validator: (v) => (v != _passwordController.text) ? 'Passwords mismatch' : null,
                          ),
                          
                          const SizedBox(height: 40),

                          // زر التسجيل
                          Consumer<AuthProvider>(
                            builder: (context, provider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 65,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.textMain,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 8,
                                  ),
                                  child: provider.isLoading
                                      ? const CupertinoActivityIndicator(color: AppColors.primary)
                                      : const Text(
                                          'INITIALIZE ACCOUNT',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
                                        ),
                                ),
                              );
                            },
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

  Widget _buildWebField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
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