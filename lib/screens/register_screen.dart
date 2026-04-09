import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/ui/main_layout.dart';
import '../core/ui/textured_background.dart';

class RegisterScreen extends StatefulWidget {
  final String verifiedPhone; // استلام الرقم الموثق من صفحة الـ OTP
  const RegisterScreen({super.key, required this.verifiedPhone});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ تثبيت الرقم الموثق في الحقل فور الدخول
    _phoneController = TextEditingController(text: widget.verifiedPhone);
  }

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
        statusBarIconBrightness: Brightness.dark,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                       'auth.complete_profile_title'.tr(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.08, 
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                       'auth.complete_profile_desc'.tr(),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // 1. الاسم
                    _buildCustomField(
                      controller: _nameController,
                      label:  'auth.full_name_label'.tr(),
                      icon: CupertinoIcons.person,
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. الإيميل
                    _buildCustomField(
                      controller: _emailController,
                      label:  'auth.email_label'.tr(),
                      icon: CupertinoIcons.mail,
                      type: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. رقم الهاتف (ReadOnly)
                    _buildCustomField(
                      controller: _phoneController,
                      label:  'auth.verified_phone_label'.tr(),
                      icon: CupertinoIcons.phone_fill,
                      enabled: false, // ✅ مقفل لأنه موثق بالـ OTP
                    ),
                    const SizedBox(height: 16),

                    // 4. كلمة المرور
                    _buildCustomField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: CupertinoIcons.lock,
                      isPassword: true,
                      validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 16),

                    // 5. تأكيد كلمة المرور
                    _buildCustomField(
                      controller: _confirmPasswordController,
                      label:  'auth.confirm_password_label'.tr(),
                      icon: CupertinoIcons.lock_shield,
                      isPassword: true,
                      validator: (value) => (value != _passwordController.text) ? 'Passwords do not match' : null,
                    ),
                    
                    const SizedBox(height: 40),
// داخل RegisterScreen تحت TextFormField بتاع الإيميل
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () { /* نداء دالة إرسال OTP للإيميل */ },
    child: const Text("Send Code to Email", style: TextStyle(color: AppColors.primary, fontSize: 12)),
  ),
),
                    // زر التسجيل
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
                            ),
                            child: provider.isLoading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                :  Text(
                                     'auth.create_account_btn'.tr(),
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
                    const SizedBox(height: 40),
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
    bool enabled = true, // ✅ أضفنا خاصية التحكم في التفعيل
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      enabled: enabled, // ✅ التحكم هنا
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 15,
        color: enabled ? AppColors.textMain : Colors.grey, // تغميق اللون لو مقفل
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMain, fontSize: 13),
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey, size: 22),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.withAlpha(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black.withAlpha(10))),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withAlpha(30))),
      ),
      validator: validator,
    );
  }
}