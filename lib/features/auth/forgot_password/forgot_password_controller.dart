import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> forgotPassword(GlobalKey<FormState> formKey) async {
    if (!_validate(formKey) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(
        email: emailController.text.trim(),
      );
      Get.snackbar(
        'Success',
        'OTP sent to your email 📧',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'email': emailController.text.trim(),
          'flow': 'forgot_password',
        },
      );
    } on NetworkException catch (error) {
      Get.snackbar(
        'Error',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
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

    if (message.contains('not found') || message.contains('no account')) {
      return 'No account found with this email';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  void sendResetInstructions() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }
    Get.snackbar(
      'Error',
      'Please enter your email address',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }
}
