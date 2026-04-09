import 'dart:convert';
import 'package:elgarage/core/constants/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/models/auth_response_model.dart';
import '../core/services/auth_service.dart';
import 'package:elgarage/providers/app_provider.dart'; 
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'ElGarage_Secure_Final', // تغيير الاسم هنا هو "السر"
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  String? _verificationId;
  User? _user; 
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
bool get isDriver => _user?.role == "DRIVER";
bool get isManager => _user?.role == "ACCOUNT_MANAGER" || _user?.role == "ADMIN";
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

// داخل AuthProvider في ملف auth_provider.dart

Future<bool> tryAutoLogin() async {
  try {
    debugPrint("🔍 Attempting AutoLogin...");
    final token = await _storage.read(key: 'accessToken');
    final userDataString = await _storage.read(key: 'user_data');

    if (token == null) {
      debugPrint("📖 Storage Token: NOT FOUND");
      return false;
    }

    _token = token;
    debugPrint("📖 Storage Token: Found");

    // محاولة استعادة البيانات من الذاكرة المحلية أولاً
    if (userDataString != null && userDataString != "null" && userDataString.isNotEmpty) {
      try {
        _user = User.fromJson(jsonDecode(userDataString));
        debugPrint("✅ AutoLogin: User ${_user?.name} restored from storage.");
      } catch (e) {
        debugPrint("⚠️ Failed to parse local user data, will fetch from API.");
      }
    }

    // ✅ صمام الأمان: لو مفيش بيانات يوزر، لازم نجيبها "ونستنى" قبل ما نرجع true
    if (_user == null) {
      debugPrint("🔄 Fetching missing user data from API...");
      await getFullProfile(); 
    }

    // التأكد النهائي: لو بعد كل ده اليوزر لسه null، يبقى فيه مشكلة في التوكن
    if (_user == null) {
      debugPrint("❌ AutoLogin Failed: Could not retrieve user profile.");
      await logout(); // امسح كل حاجة عشان يبدأ نظيف
      return false;
    }

    notifyListeners();
    return true; 
  } catch (e) {
    debugPrint("❌ AutoLogin Critical Error: $e");
    return false;
  }
}

// تعديل بسيط في دالة الحفظ لزيادة الأمان
Future<void> _saveAuthData(String token, User user) async {
  try {
    await _storage.write(key: 'accessToken', value: token);
    await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    debugPrint("💾 Auth data successfully persisted.");
  } catch (e) {
    debugPrint("❌ Failed to save auth data: $e");
  }
}

 Future<void> getFullProfile() async {
  if (_token == null) return;
  try {
    final response = await http.get(
      Uri.parse(AppConfig.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _user = User.fromJson(responseData['data'] ?? responseData);
      
      // ✅ حفظ البيانات المحدثة فوراً لضمان بقاء السيشن كاملة
      await _saveAuthData(_token!, _user!); 
      notifyListeners();
    }
  } catch (e) {
    debugPrint("❌ Profile Sync Error: $e");
  }
}

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _token = response.accessToken;
      
      // ✅ حفظ البيانات بالمفاتيح الصحيحة
      await _saveAuthData(_token!, _user!);
      await _storage.write(key: 'user_role', value: response.user.role);
      await getFullProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Login Failed: Check your credentials";
      notifyListeners();
      return false;
    }
  }
 Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authService.register(name, email, phone, password);
      _user = response.user;
      _token = response.accessToken;
      
      // ✅ حفظ البيانات بالمفاتيح الصحيحة
      await _saveAuthData(_token!, _user!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

Future<void> logout([AppProvider? appProvider]) async {
  await _storage.deleteAll(); // ✅ يمسح كل شيء (التوكن واليوزر) لضمان نظافة الجلسة
  _token = null;
  _user = null;
  if (appProvider != null) appProvider.resetOnLogout();
  notifyListeners();
  debugPrint("🚪 Logged out: Storage wiped clean.");
}

// أضفها بعد دالة logout الحالية
void handleUnauthorized() {
  _token = null;
  _user = null;
  _storage.deleteAll(); // تنظيف شامل
  notifyListeners(); // سيؤدي هذا لتغيير واجهة InitialRouter فوراً للوجن
  debugPrint("🚨 Session Expired: Global logout triggered.");
}

  // --- FIREBASE PHONE AUTH ---
  Future<void> sendOtp(String phoneNumber, Function(String) onCodeSent) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          _isLoading = false;
          _errorMessage = e.message;
          notifyListeners();
        },
        codeSent: (String verId, int? resendToken) {
          _verificationId = verId;
          _isLoading = false;
          notifyListeners();
          onCodeSent(verId);
        },
        codeAutoRetrievalTimeout: (String verId) => _verificationId = verId,
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ✅ تعديل: ترجع رقم الهاتف لتمكينه في صفحة التسجيل
  Future<String?> verifyOtp(String smsCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      fb_auth.PhoneAuthCredential credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return result.user?.phoneNumber; 
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Invalid Verification Code";
      notifyListeners();
      return null;
    }
  }
  // داخل كلاس AuthProvider

// 1. دالة تغيير الباسوورد (بترسل طلب للباك إند)
Future<bool> changePassword(String newPassword, String text) async {
  // هنا هتنادي على الـ API الخاص بـ Beyond AI
  // مثال: await _authService.updatePassword(newPassword);
  return true; 
}

// 2. دالة مسح الحساب
Future<bool> deleteAccount() async {
  try {
    // نداء الـ API الخاص بمسح البيانات (User Data Deletion URL)
    // await _authService.deleteAccount();
    await logout(); // تسجيل خروج بعد المسح
    return true;
  } catch (e) {
    return false;
  }
}

}