import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to proceed',
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      _handleError(e);
      return false;
    }
  }

  void _handleError(PlatformException e) {
    String message = 'Authentication failed';
    switch (e.code) {
      case 'NotAvailable':
        message = 'Biometric authentication is not available on this device';
        break;
      case 'NotEnrolled':
        message = 'No biometrics are enrolled on this device';
        break;
      case 'LockedOut':
        message = 'Biometric authentication is locked out due to too many attempts';
        break;
      case 'PermanentlyLockedOut':
        message = 'Biometric authentication is permanently locked out. Please use device PIN';
        break;
      case 'OtherOperatingSystem':
        message = 'Biometric authentication is not supported on this operating system';
        break;
      default:
        message = e.message ?? 'Authentication failed';
    }
    
    Get.snackbar(
      'Biometric',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
