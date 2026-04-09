class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? organizationName;
  final String? organizationId; // ✅ لازم السطر ده يكون موجود

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.organizationName, 
    this.organizationId, // ✅ ولازم يكون هنا
  });

  // داخل كلاس User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'User',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      organizationName: json['organizationName'] ?? json['organization']?['name'],
      organizationId: json['organizationId']?.toString() ?? json['organization']?['id']?.toString(), // ✅ استخراج الـ ID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'organizationName': organizationName,
      'organizationId': organizationId, // ✅ حفظ الـ ID لضمان ظهوره بعد الريستارت
    };
  }
}

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