import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

import '../../core/services/biometric_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = Get.put(BiometricService());

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await _storageService.getAuthToken();
    final isLoggedIn = await _storageService.isLoggedIn();

    if (token != null && token.isNotEmpty && isLoggedIn) {
      final bool isBiometricEnabled = await _storageService.isBiometricEnabled();
      
      if (isBiometricEnabled) {
        final bool authenticated = await _biometricService.authenticate();
        if (authenticated) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          // If authentication fails or is cancelled, stay on splash or show retry
          // For better UX, we can show a "Retry" button on Splash or just go to Login
          // But usually, if they fail biometric, we should let them use password
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
