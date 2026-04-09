import 'package:easy_localization/easy_localization.dart';
// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/ui/textured_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _emailController;
  @override
  void initState() {
    super.initState();
    // الحصول على الإيميل الحالي من الـ Provider
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title:  Text( 'profile.title'.tr(), 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: AppColors.textMain)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.textMain,
                child: Icon(CupertinoIcons.person_alt_circle_fill, size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: 30),

              // 1. الاسم بالكامل (ثابت حالياً)
              _buildProfileField( 'profile.full_name_field'.tr(), user?.name ?? "N/A", CupertinoIcons.person),

              // 2. البريد الإلكتروني (قابل للتعديل + Verify)
              _buildEditableEmailField(authProvider),

              // 3. رقم الهاتف (موثق ✅)
              _buildProfileField(
                 'profile.phone_field'.tr(), 
                user?.phone ?? "N/A", 
                CupertinoIcons.phone,
                trailing: const Icon(Icons.verified, color: Colors.green, size: 18),
              ),

              // 4. نوع الحساب
              _buildProfileField( 'profile.account_type_field'.tr(), user?.role ?? "CUSTOMER", CupertinoIcons.shield_fill),

              const SizedBox(height: 25),

              // 5. زر تغيير كلمة المرور
              _buildActionButton(
                label:  'profile.change_password_btn'.tr(),
                icon: CupertinoIcons.lock_shield,
                onTap: () => _showChangePasswordDialog(context, authProvider),
              ),

              const SizedBox(height: 15),

              // 6. زر حذف الحساب
              _buildActionButton(
                label:  'profile.delete_account_btn'.tr(),
                icon: CupertinoIcons.trash,
                isDanger: true,
                onTap: () => _showDeleteConfirmation(context, authProvider),
              ),

              const SizedBox(height: 40),
              const Text("EL GARAGE SYSTEM v1.0", 
                style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ويجت حقل الإيميل القابل للتعديل مع زر الـ Verify
  Widget _buildEditableEmailField(AuthProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.mail, color: AppColors.primary, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text( 'profile.email_field'.tr(), style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _emailController,
                  onChanged: (val) => setState(() {}), // لتحديث حالة الزرار عند الكتابة
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                    border: InputBorder.none,
                    hintText: "Enter your email",
                  ),
                ),
              ],
            ),
          ),
          // زر الـ Verify (يظهر فقط لو الإيميل مكتوب)
          if (_emailController.text.contains('@'))
            InkWell(
              onTap: () => _handleEmailVerifyRequest(context, provider, _emailController.text.trim()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.4))
                ),
                child:  Text( 'profile.verify_now_btn'.tr(), 
                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  // --- دالة طلب توثيق الإيميل (بتاخد الإيميل المكتوب حالياً) ---
  void _handleEmailVerifyRequest(BuildContext context, AuthProvider provider, String email) async {
    // عرض لودينج
    showCupertinoDialog(
      context: context,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );

    debugPrint("📧 Requesting OTP for Email: $email");
    
    // محاكاة إرسال للباك إند
    await Future.delayed(const Duration(seconds: 2)); 
    
    if (context.mounted) {
      Navigator.pop(context); // قفل اللودينج
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A verification code has been sent to: $email"),
          backgroundColor: Colors.blueAccent,
        )
      );
      // هنا تفتح صفحة الـ OTP الخاصة بالإيميل
    }
  }

  // ويجت الحقول الثابتة
  Widget _buildProfileField(String label, String value, IconData icon, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ويجت الأزرار
  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap, bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.withOpacity(0.05) : AppColors.textMain.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDanger ? Colors.red.withOpacity(0.2) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDanger ? Colors.red : AppColors.primary, size: 20),
            const SizedBox(width: 15),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 13, 
              color: isDanger ? Colors.red : AppColors.textMain
            )),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDanger ? Colors.red : AppColors.textMain.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  // --- ديالوج حذف الحساب ---
  void _showDeleteConfirmation(BuildContext context, AuthProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title:  Text( 'profile.delete_confirm_title'.tr()),
        content: const Text("Permanent action. All data will be removed."),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteAccount();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // --- ديالوج تغيير الباسوورد (شكلي حالياً للبرودكشن) ---
  void _showChangePasswordDialog(BuildContext context, AuthProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password change will be active in Production.")));
  }
}