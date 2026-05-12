import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _userImageKey = 'user_image';
  static const String _userSpecialtyKey = 'user_specialty';
  static const String _userHospitalNameKey = 'user_hospital_name';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userStatusKey = 'user_status';
  static const String _userVerifiedKey = 'user_verified';
  static const String _biometricEnabledKey = 'biometric_enabled';

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
    String? userImage,
    String? userSpecialty,
    String? userHospitalName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setString(_userRoleKey, userRole);
    if (userImage != null && userImage.isNotEmpty) {
      await prefs.setString(_userImageKey, userImage);
    } else {
      await prefs.remove(_userImageKey);
    }
    if (userSpecialty != null) {
      await prefs.setString(_userSpecialtyKey, userSpecialty);
    } else {
      await prefs.remove(_userSpecialtyKey);
    }
    if (userHospitalName != null) {
      await prefs.setString(_userHospitalNameKey, userHospitalName);
    } else {
      await prefs.remove(_userHospitalNameKey);
    }
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
    String? userImage,
    String? userSpecialty,
    String? userHospitalName,
    String? userStatus,
    bool? userVerified,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setString(_userRoleKey, userRole);
    if (userImage != null && userImage.isNotEmpty) {
      await prefs.setString(_userImageKey, userImage);
    } else {
      await prefs.remove(_userImageKey);
    }
    if (userSpecialty != null) {
      await prefs.setString(_userSpecialtyKey, userSpecialty);
    } else {
      await prefs.remove(_userSpecialtyKey);
    }
    if (userHospitalName != null) {
      await prefs.setString(_userHospitalNameKey, userHospitalName);
    } else {
      await prefs.remove(_userHospitalNameKey);
    }
    if (userStatus != null) {
      await prefs.setString(_userStatusKey, userStatus);
    } else {
      await prefs.remove(_userStatusKey);
    }
    if (userVerified != null) {
      await prefs.setBool(_userVerifiedKey, userVerified);
    } else {
      await prefs.remove(_userVerifiedKey);
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userImageKey);
    await prefs.remove(_userSpecialtyKey);
    await prefs.remove(_userHospitalNameKey);
    await prefs.remove(_userStatusKey);
    await prefs.remove(_userVerifiedKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  Future<String?> getUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userImageKey);
  }

  Future<String?> getUserSpecialty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userSpecialtyKey);
  }

  Future<String?> getUserHospitalName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userHospitalNameKey);
  }

  Future<String?> getUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userStatusKey);
  }

  Future<bool?> getUserVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userVerifiedKey);
  }
}
