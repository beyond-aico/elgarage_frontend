import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/ui/main_layout.dart';
import '../core/ui/textured_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // أيقونات سوداء لأن الخلفية هنا فاتحة
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TexturedBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // 1. زر الرجوع في أعلى الصفحة تماماً
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textMain),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // 2. العنوان الرئيسي (Top Aligned)
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.08, 
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join us to take care of your car',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    
                    const SizedBox(height: 40),

                    // 3. الحقول (Fields)
                    _buildCustomField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: CupertinoIcons.person,
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildCustomField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: CupertinoIcons.mail,
                      type: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildCustomField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: CupertinoIcons.phone,
                      type: TextInputType.phone,
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter phone' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildCustomField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: CupertinoIcons.lock,
                      isPassword: true,
                      validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildCustomField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: CupertinoIcons.lock_shield,
                      isPassword: true,
                      validator: (value) => (value != _passwordController.text) ? 'Not matching' : null,
                    ),
                    
                    const SizedBox(height: 40),

                    // 4. زر التسجيل المانجاوي
                    Consumer<AuthProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
backgroundColor: AppColors.textMain,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                              shadowColor: const Color.fromARGB(255, 44, 40, 36).withAlpha(100),
                            ),
                            child: provider.isLoading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary, 
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40), // مساحة لراحة السكرول
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomField({
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
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMain, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withAlpha(10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withAlpha(5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}