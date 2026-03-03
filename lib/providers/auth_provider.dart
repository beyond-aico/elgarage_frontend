import 'dart:convert';

import 'package:elgarage/core/constants/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/models/auth_response_model.dart';
import '../core/services/auth_service.dart';
import 'package:elgarage/providers/app_provider.dart'; // ده هيحل error الـ Undefined class
class AuthProvider with ChangeNotifier {
  // بنستخدم السرفيس الخاصة بالباك إند بتاعنا بس
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

// 1. دالة جديدة لجلب البروفايل الكامل من الباك إند
  Future<void> getFullProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse(AppConfig.profile), // المسار: /api/v1/users/profile
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // الباك إند يرسل البيانات مغلفة في حقل data
        final userData = responseData['data'] ?? responseData;
        
        // تحديث كائن المستخدم بالبيانات الكاملة (اسم، تليفون، دور، منظمة)
        _user = User.fromJson(userData);
        notifyListeners();
        debugPrint("👤 Profile Sync Complete: ${_user?.name}");
      }
    } catch (e) {
      debugPrint("❌ Profile Sync Error: $e");
    }
  }

  // 2. تحديث دالة الـ Login لعمل Sync للبروفايل فوراً
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _token = response.accessToken;
      
      await _storage.write(key: 'accessToken', value: _token);
      
      // ✅ الخطوة الإضافية: جلب البروفايل الكامل لضمان تحديث كل الحقول في الـ UI
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

// لاحظ الأقواس المربعة [ ] دي بتخلي البروفايدر اختياري
Future<void> logout([AppProvider? appProvider]) async {
  await _storage.delete(key: 'accessToken');
  _token = null;
  _user = null;

  // لو بعتنا البروفايدر (زي ما هنعمل في الـ UI)، نضف الداتا
  if (appProvider != null) {
    appProvider.clearData();
  }
  
  notifyListeners();
}

// --- الفحص التلقائي للجلسة عند فتح التطبيق ---
  Future<bool> tryAutoLogin() async {
    _token = await _storage.read(key: 'accessToken');
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse(AppConfig.profile), 
        headers: {'Authorization': 'Bearer $_token'},
      );

     // --- التعديل في ملف lib/providers/auth_provider.dart ---

// داخل دالة tryAutoLogin ابحث عن سطر الـ JSON
if (response.statusCode == 200) {
  final responseData = jsonDecode(response.body);
  final userData = responseData['data'] ?? responseData;
  _user = User.fromJson(userData);
  
  // 🔥 إضافة: تحديث الـ AppProvider باسم الشركة فوراً
  // سنحتاج لتمرير اسم الشركة للـ AppProvider لاحقاً
  notifyListeners();
  return true;
} else {
        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("🚀 1. Starting Registration..."); // طباعة 1
    try {
      print("⏳ 2. Sending Request to Backend...");
      final response = await _authService.register(name, email, phone, password);
      
      print("✅ 3. Success! Token received: ${response.accessToken}");
      _user = response.user;
      _token = response.accessToken;

      await _storage.write(key: 'accessToken', value: _token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ 4. Error Occurred: $e"); // هنا هنعرف السبب الحقيقي
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}