import 'shop_info.dart';

class User {
  final int id;
  final String username;
  final String fullName;
  final String? email; // New field
  final String role;
  final bool? isEmailVerified; // New field
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.role,
    this.isEmailVerified,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['username'] ?? 'Unknown',
      email: json['email'],
      role: json['role'] ?? 'user',
      isEmailVerified: json['is_email_verified'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final String token;
  final User user;
  final ShopInfo? shopInfo;

  LoginData({required this.token, required this.user, this.shopInfo});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      user: User.fromJson(json['user']),
      shopInfo: json['shop_info'] != null
          ? ShopInfo.fromJson(json['shop_info'])
          : null,
    );
  }
}
