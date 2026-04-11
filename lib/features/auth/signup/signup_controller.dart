import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class SignupController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signUp(GlobalKey<FormState> formKey) async {
    if (!_validate(formKey) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.snackbar(
        'Success',
        'Account created successfully 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(
        AppRoutes.login,
        arguments: {'email': emailController.text.trim()},
      );
    } on NetworkException catch (error) {
      Get.snackbar(
        'Sign up failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Sign up failed',
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

    if (message.contains('already') || message.contains('exists')) {
      return 'This email is already registered';
    }

    if (message.contains('invalid') ||
        message.contains('required') ||
        message.contains('missing') ||
        message.contains('fill')) {
      return 'Please fill all fields correctly';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
