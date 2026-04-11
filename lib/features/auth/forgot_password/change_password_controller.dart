import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final AuthRepository _authRepository = AuthRepository();
  String email = '';
  String resetToken = '';

  ChangePasswordController() {
    final arguments = Get.arguments;
    if (arguments is Map && arguments['email'] != null) {
      email = arguments['email'].toString();
    }
    if (arguments is Map && arguments['resetToken'] != null) {
      resetToken = arguments['resetToken'].toString();
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!_validate()) {
      return;
    }

    if (resetToken.isEmpty) {
      Get.snackbar(
        'Reset failed',
        'Reset token not found. Please verify OTP again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.resetPassword(
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        resetToken: resetToken,
      );
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.snackbar(
        'Success',
        'Password reset successfully 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    } on NetworkException catch (error) {
      Get.snackbar(
        'Reset failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Reset failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Reset failed',
        'Please fill all fields correctly',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Reset failed',
        'Please fill all fields correctly',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Reset failed',
        'Passwords do not match',
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

    if (message.contains('match') || message.contains('mismatch')) {
      return 'Passwords do not match';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}