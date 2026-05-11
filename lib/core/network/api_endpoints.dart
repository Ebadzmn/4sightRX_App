import '../utils/app_constants.dart';

class ApiEndpoints {
  static const String baseUrl = AppConstants.baseUrl;
  static const String login = '/auth/login';
  static const String signUp = '/user';
  static const String organizations = '/organizations';
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String patients = '/patients';
  static const String medications = '/medications';
  static const String medicationsBulk = '/medications/bulk';
  static const String stats = '/analytics/app/analytics';
  static const String allergies = '/allergies';
  static const String monthlySavings = '/analytics/monthly-savings';
  static const String extractMedicationText = '/medications/extract-text';
  static const String formularyComparisonAnalyze =
      '/formulary-comparison/analyze';
  static const String formularyComparisonSummary =
      '/formulary-comparison/summary';
  static String formularyComparisonAction(String comparisonId) {
    return '/formulary-comparison/$comparisonId/action';
  }

  static String patientDetail(String patientId) {
    return '$patients/${Uri.encodeComponent(patientId)}';
  }

  static const String forgetPassword = '/auth/forget-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resetPassword = '/auth/reset-password';
}
