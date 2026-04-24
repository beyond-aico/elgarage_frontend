import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'otp_verification_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../core/app_ui/textured_background.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('auth.phone_auth_title'.tr(), 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)), 
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "auth.phone_auth_desc".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: "auth.phone_hint".tr(),
                  prefixText: "+20 ", 
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black.withAlpha(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () {
                    String phone = _phoneController.text.trim();
                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("auth.enter_phone_error".tr()))
                      );
                      return;
                    }

                    phone = phone.replaceAll(RegExp(r'\s+'), '');
                    if (!phone.startsWith('+')) {
                      if (phone.startsWith('0')) {
                        phone = '+20${phone.substring(1)}';
                      } else if (phone.startsWith('20')) {
                        phone = '+$phone';
                      } else {
                        phone = '+20$phone';
                      }
                    }

                    auth.sendOtp(phone, (verId) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpVerificationScreen()));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textMain,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: Colors.black.withAlpha(50),
                  ),
                  child: auth.isLoading 
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : Text('auth.send_code_btn'.tr(), 
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}