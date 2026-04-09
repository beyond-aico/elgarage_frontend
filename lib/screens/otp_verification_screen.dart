import 'package:easy_localization/easy_localization.dart';
// lib/screens/auth/otp_verification_screen.dart
import 'dart:async';
import 'package:elgarage/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/ui/textured_background.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _secondsRemaining = 60; // مدة المؤقت
  Timer? _timer;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // تصميم خانات الكود (Modern Industrial Style)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withAlpha(10)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: TexturedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // زر الرجوع
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.primary),
                const SizedBox(height: 30),
                 Text(
                   'auth.otp_title'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textMain, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please enter the 6-digit code sent to your phone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 50),

                // خانات إدخال الـ OTP
                Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: (pin) async {
                    final phoneNumber = await auth.verifyOtp(pin);
                    if (phoneNumber != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen(verifiedPhone: phoneNumber)),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid code, please try again"), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),

                const SizedBox(height: 40),

                // المؤقت وزر إعادة الإرسال
                Column(
                  children: [
                    if (_secondsRemaining > 0)
                      Text(
                        "Resend code in 00:$_secondsRemaining",
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      )
                    else
                      TextButton(
                        onPressed: auth.isLoading ? null : () async {
                          // نحتاج لتخزين الرقم في AuthProvider أو تمريره هنا لإعادة الإرسال
                          // سنفترض أننا سنعود للخلف لإعادة الإدخال أو نستخدم الرقم المخزن
                          _startTimer();
                          // auth.sendOtp(currentPhone, (id) => {});
                        },
                        child:  Text(
                           'auth.resend_btn'.tr(),
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 40),
                
                // حالة التحميل
                if (auth.isLoading)
                  const CupertinoActivityIndicator(radius: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}