import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../../core/services/storage_service.dart';
import '../models/login_response.dart';
import '../models/sign_up_request.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient, StorageService? storageService})
    : _apiClient = apiClient ?? ApiClient.instance,
      _storageService = storageService ?? StorageService();

  final ApiClient _apiClient;
  final StorageService _storageService;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final loginResponse = LoginResponse.fromJson(responseData);
    if (!loginResponse.success) {
      throw NetworkException(
        message: loginResponse.message.isNotEmpty
            ? loginResponse.message
            : 'Something went wrong. Try again',
        statusCode: response.statusCode,
      );
    }

    final token = loginResponse.data?.token;
    final user = loginResponse.data?.user;

    if (token == null || token.isEmpty || user == null) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    await _storageService.saveAuthData(
      token: token,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      userImage: user.image,
    );

    return loginResponse;
  }

  Future<void> signUp({required SignUpRequest request}) async {
    final response = await _apiClient.post(
      ApiEndpoints.signUp,
      body: request.toJson(),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapSignUpError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    if (data is Map<String, dynamic>) {
      final name = data['name']?.toString() ?? '';
      final firstName = data['firstName']?.toString() ?? '';
      final lastName = data['lastName']?.toString() ?? '';
      final resolvedName = name.isNotEmpty
          ? name
          : [firstName, lastName]
              .where((part) => part.trim().isNotEmpty)
              .join(' ');

      await _storageService.saveUserData(
        userId: data['_id'] as String? ?? '',
        userName: resolvedName,
        userEmail: data['email'] as String? ?? '',
        userRole: data['role'] as String? ?? '',
        userImage: data['image'] as String? ?? '',
        userStatus: data['status']?.toString(),
        userVerified: data['verified'] as bool?,
      );
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw NetworkException(message: 'Something went wrong. Try again');
      }

      final success = responseData['success'] as bool? ?? false;
      final message = responseData['message'] as String? ?? '';
      final data = responseData['data'];

      if (!success) {
        throw NetworkException(
          message: _mapProfileError(
            message: message,
            statusCode: response.statusCode,
          ),
          statusCode: response.statusCode,
        );
      }

      if (data is! Map<String, dynamic>) {
        throw NetworkException(message: 'Something went wrong. Try again');
      }

      final userProfile = UserModel.fromJson(data);
      await _storageService.saveUserData(
        userId: userProfile.id,
        userName: userProfile.name,
        userEmail: userProfile.email,
        userRole: userProfile.role,
        userImage: userProfile.resolvedImagePath,
        userSpecialty: userProfile.specialty,
        userHospitalName: userProfile.hospitalName,
        userStatus: userProfile.status,
        userVerified: userProfile.verified,
      );

      return userProfile;
    } on NetworkException catch (error) {
      if (error.statusCode == 401) {
        rethrow;
      }

      throw NetworkException(
        message: _mapProfileError(
          message: error.message,
          statusCode: error.statusCode,
        ),
        statusCode: error.statusCode,
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgetPassword,
      body: {'email': email},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';

    if (!success) {
      throw NetworkException(
        message: _mapForgotPasswordError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  Future<String> verifyEmail({
    required String email,
    required int oneTimeCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyEmail,
      body: {'email': email, 'oneTimeCode': oneTimeCode},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final resetToken = responseData['data']?.toString() ?? '';

    if (!success) {
      throw NetworkException(
        message: _mapVerifyEmailError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    if (resetToken.isEmpty) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    return resetToken;
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      body: {'newPassword': newPassword, 'confirmPassword': confirmPassword},
      options: Options(headers: {'Authorization': resetToken}),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';

    if (!success) {
      throw NetworkException(
        message: _mapResetPasswordError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? specialty,
    String? hospitalName,
    File? imageFile,
  }) async {
    final formFields = <String, dynamic>{};

    if (name != null && name.trim().isNotEmpty) {
      formFields['name'] = name.trim();
    }
    if (specialty != null && specialty.trim().isNotEmpty) {
      formFields['specialty'] = specialty.trim();
    }
    if (hospitalName != null && hospitalName.trim().isNotEmpty) {
      formFields['hospitalName'] = hospitalName.trim();
    }
    if (imageFile != null) {
      formFields['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      );
    }

    final response = await _apiClient.patch(
      ApiEndpoints.updateProfile,
      body: FormData.fromMap(formFields),
      options: Options(contentType: 'multipart/form-data'),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapUpdateProfileError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final updatedUser = UserModel.fromJson(data);
    await _storageService.saveUserData(
      userId: updatedUser.id,
      userName: updatedUser.name,
      userEmail: updatedUser.email,
      userRole: updatedUser.role,
      userImage: updatedUser.resolvedImagePath,
      userSpecialty: updatedUser.specialty,
      userHospitalName: updatedUser.hospitalName,
      userStatus: updatedUser.status,
      userVerified: updatedUser.verified,
    );

    return updatedUser;
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    _apiClient.clearToken();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';

    if (!success) {
      throw NetworkException(
        message: _mapChangePasswordError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  String _mapChangePasswordError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (lowerMessage.contains('incorrect') ||
        lowerMessage.contains('current') ||
        lowerMessage.contains('password')) {
      return 'Incorrect current password';
    }

    if (lowerMessage.contains('match') || lowerMessage.contains('mismatch')) {
      return 'Passwords do not match';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Something went wrong. Try again';
  }

  String _mapSignUpError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (lowerMessage.contains('already') || lowerMessage.contains('exists')) {
      return 'This email is already registered';
    }

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('required') ||
        lowerMessage.contains('missing') ||
        lowerMessage.contains('fill')) {
      return 'Please fill all fields correctly';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  String _mapForgotPasswordError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (lowerMessage.contains('not found') || lowerMessage.contains('email')) {
      return 'No account found with this email';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  String _mapVerifyEmailError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (lowerMessage.contains('invalid')) {
      return 'Invalid verification code';
    }

    if (lowerMessage.contains('expired')) {
      return 'Code expired. Request a new one';
    }

    if (lowerMessage.contains('not found') || lowerMessage.contains('email')) {
      return 'No account found with this email';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  String _mapResetPasswordError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (lowerMessage.contains('match') || lowerMessage.contains('mismatch')) {
      return 'Passwords do not match';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  String _mapProfileError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (statusCode == 404 || lowerMessage.contains('not found')) {
      return 'Profile not found';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  String _mapUpdateProfileError({required String message, int? statusCode}) {
    final lowerMessage = message.toLowerCase();

    if (statusCode == 500 || lowerMessage.contains('server')) {
      return 'Server error. Please try again';
    }

    if (statusCode == 404 || lowerMessage.contains('not found')) {
      return 'Profile not found';
    }

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('file') ||
        lowerMessage.contains('type')) {
      return 'Please select a valid image';
    }

    if (lowerMessage.contains('large') || lowerMessage.contains('size')) {
      return 'Image size too large';
    }

    if (lowerMessage.contains('internet') ||
        lowerMessage.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
