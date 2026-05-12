import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  void toggleCurrentPasswordVisibility() => isCurrentPasswordVisible.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (current.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Missing information', 'Please fill in all password fields.');
      return;
    }

    if (newPassword.length < 8) {
      _showError('Invalid Password', 'New password must be at least 8 characters long.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match', 'New password and confirmation must be the same.');
      return;
    }

    if (current == newPassword) {
      _showError('Duplicate Password', 'New password cannot be the same as current password.');
      return;
    }

    isLoading.value = true;

    try {
      await _authRepository.changePassword(
        currentPassword: current,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      Get.snackbar(
        'Success',
        'Your password has been changed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Delay to show snackbar then go back
      Future.delayed(const Duration(seconds: 1), () => Get.back());
    } on NetworkException catch (e) {
      _showError('Error', e.message);
    } catch (e) {
      _showError('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}

