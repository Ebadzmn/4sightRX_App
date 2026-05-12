import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/storage_service.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool canLoginWithBiometric = false.obs;

  final AuthRepository _authRepository = AuthRepository();
  final BiometricService _biometricService = Get.put(BiometricService());
  final StorageService _storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final bool isEnabled = await _storageService.isBiometricEnabled();
    final bool isAvailable = await _biometricService.isBiometricAvailable();
    final bool hasEnrolled = await _biometricService.hasEnrolledBiometrics();
    final bool isLoggedInBefore = await _storageService.isLoggedIn();

    canLoginWithBiometric.value = isEnabled && isAvailable && hasEnrolled && isLoggedInBefore;
    
    if (canLoginWithBiometric.value) {
      // Auto-trigger biometric login after a small delay to let UI render
      Future.delayed(const Duration(milliseconds: 500), () {
        biometricLogin();
      });
    }
  }

  Future<void> biometricLogin() async {
    if (isLoading.value) return;

    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      isLoading.value = true;
      try {
        // Since we are already "logged in" (have tokens), we can just go to home
        // The middleware or Splash usually handles this, but here we are on Login page
        // which means user might have logged out or token expired.
        // If they enabled biometric, we assume the token is still valid or we should
        // refresh it. For now, we follow the requirement: "Authenticate user before granting access."
        
        final token = await _storageService.getAuthToken();
        if (token != null && token.isNotEmpty) {
          Get.snackbar(
            'Success',
            'Authenticated successfully! 👋',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar(
            'Authentication',
            'Please login with your email and password first to enable biometric.',
            snackPosition: SnackPosition.BOTTOM,
          );
          canLoginWithBiometric.value = false;
          await _storageService.setBiometricEnabled(false);
        }
      } catch (_) {
        Get.snackbar(
          'Error',
          'Something went wrong during biometric login.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (!_validate(formKey) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.snackbar(
        'Success',
        'Welcome back! 👋',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.home);
    } on NetworkException catch (error) {
      Get.snackbar(
        'Login failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Login failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(GlobalKey<FormState> formKey) {
    final formState = formKey.currentState;
    if (formState == null) {
      return false;
    }
    return formState.validate();
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('verify')) {
      return 'Please verify your email first';
    }

    if (message.contains('not found') || message.contains('no account')) {
      return 'No account found with this email';
    }

    if (message.contains('invalid') ||
        message.contains('wrong password') ||
        error.statusCode == 401) {
      return 'Invalid email or password';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
