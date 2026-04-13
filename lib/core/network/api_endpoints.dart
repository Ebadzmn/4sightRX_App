import '../utils/app_constants.dart';

class ApiEndpoints {
  static const String baseUrl = AppConstants.baseUrl;
  static const String login = '/auth/login';
  static const String signUp = '/user';
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String patients = '/patients';
  static const String forgetPassword = '/auth/forget-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resetPassword = '/auth/reset-password';
}
