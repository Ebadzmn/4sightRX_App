import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/storage_service.dart';

class ProfileController extends GetxController {
  final RxBool isFaceIdEnabled = false.obs;
  final AuthRepository _authRepository = AuthRepository();
  final BiometricService _biometricService = Get.put(BiometricService());
  final StorageService _storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    isFaceIdEnabled.value = await _storageService.isBiometricEnabled();
  }

  Future<void> toggleFaceId(bool value) async {
    if (value) {
      // Enabling Biometric
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        Get.snackbar(
          'Not Supported',
          'Biometric authentication is not supported on this device.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      if (!hasEnrolled) {
        Get.snackbar(
          'No Biometrics',
          'No biometrics enrolled. Please set up Face ID/Touch ID in your device settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        isFaceIdEnabled.value = true;
        await _storageService.setBiometricEnabled(true);
      }
    } else {
      // Disabling Biometric
      isFaceIdEnabled.value = false;
      await _storageService.setBiometricEnabled(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
