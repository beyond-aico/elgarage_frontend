// --- التعديل في ملف lib/core/models/auth_response_model.dart ---

class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? organizationName; // ✅ إضافة هذا الحقل لإظهار اسم الشركة (فودافون مثلاً)

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.organizationName, 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // الباك إند أحياناً بيبعت بيانات المنظمة متداخلة
    String? orgName;
    if (json['organization'] != null && json['organization'] is Map) {
      orgName = json['organization']['name'];
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'User',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      organizationName: orgName, // ✅ سحب اسم الشركة لو موجود
    );
  }
}
// بقية ملف AuthResponse تظل كما هي

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // الباك إند (NestJS) بيلف الداتا في حقل اسمه data
    final data = json['data'] ?? json; 
    
    return AuthResponse(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      user: User.fromJson(data['user'] ?? {}),
    );
  }
}