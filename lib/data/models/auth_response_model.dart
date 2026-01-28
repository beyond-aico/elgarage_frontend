class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
    );
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
    // حسب هيكل الرد اللي شفناه في Postman (data جواها accessToken)
    final data = json['data']; 
    return AuthResponse(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      user: User.fromJson(data['user']),
    );
  }
}