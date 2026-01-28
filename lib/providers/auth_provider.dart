import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/auth_response_model.dart';
import '../data/services/auth_service.dart';

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

  Null get currentUser => null;

  // --- Login (Email/Password) ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _token = response.accessToken;
      
      await _storage.write(key: 'accessToken', value: _token);
      
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

  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("🚀 1. Starting Registration..."); // طباعة 1
print("📡 Target IP: 192.168.8.15");
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
  
  void logout() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'accessToken');
    notifyListeners();
  }
}