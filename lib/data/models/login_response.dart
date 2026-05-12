import '../../core/utils/app_constants.dart';

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  const LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginData {
  final String token;
  final UserModel? user;

  const LoginData({required this.token, this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String? ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String image;
  final String specialty;
  final String hospitalName;
  final String status;
  final bool verified;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.image,
    this.specialty = '',
    this.hospitalName = '',
    this.status = '',
    this.verified = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String name = json['name'] as String? ?? '';
    if (name.isEmpty) {
      final firstName = json['firstName'] as String? ?? '';
      final lastName = json['lastName'] as String? ?? '';
      name = '$firstName $lastName'.trim();
    }

    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: name,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      image: json['image'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      status: json['status']?.toString() ?? '',
      verified: json['verified'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  String get resolvedImageUrl {
    return resolvedImagePath;
  }

  String get resolvedImagePath {
    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http')) {
      return image;
    }

    return '${AppConstants.imageBaseUrl}$image';
  }
}
