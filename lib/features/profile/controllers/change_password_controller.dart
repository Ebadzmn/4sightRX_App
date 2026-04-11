import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void changePassword() {
    final current = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (current.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Missing information',
        'Please fill in all password fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Passwords do not match',
        'New password and confirmation must be the same.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.snackbar(
      'Password updated',
      'Your password has been changed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    Get.back();
  }
}

