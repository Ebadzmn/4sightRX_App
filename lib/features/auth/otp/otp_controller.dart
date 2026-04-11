import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs;

  final AuthRepository _authRepository = AuthRepository();

  String email = '';
  String flow = 'signup';

  OtpController() {
    final arguments = Get.arguments;
    if (arguments is Map) {
      email = arguments['email']?.toString() ?? '';
      flow = arguments['flow']?.toString() ?? 'signup';
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  Future<void> verifyEmail() async {
    final otpValue = int.tryParse(otpController.text.trim());
    if (!_validate(otpValue)) {
      return;
    }

    isLoading.value = true;
    try {
      final resetToken = await _authRepository.verifyEmail(
        email: email,
        oneTimeCode: otpValue!,
      );
      Get.snackbar(
        'Success',
        'OTP verified successfully ✅',
        snackPosition: SnackPosition.BOTTOM,
      );

      if (flow == 'forgot_password') {
        Get.toNamed(
          AppRoutes.changePassword,
          arguments: {
            'email': email,
            'resetToken': resetToken,
          },
        );
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } on NetworkException catch (error) {
      Get.snackbar(
        'Verification failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Verification failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(int? otpValue) {
    if (email.isEmpty) {
      Get.snackbar(
        'Verification failed',
        'Email not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        'Verification failed',
        'Please enter the verification code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (otpController.text.trim().length != 4) {
      Get.snackbar(
        'Verification failed',
        'OTP must be exactly 4 digits',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (otpValue == null) {
      Get.snackbar(
        'Verification failed',
        'Please enter a numeric code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('invalid')) {
      return 'Invalid verification code';
    }

    if (message.contains('expired')) {
      return 'Code expired. Request a new one';
    }

    if (message.contains('not found')) {
      return 'No account found with this email';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}