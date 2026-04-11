import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final AuthRepository _authRepository = AuthRepository();

  @override
  void onInit() {
    super.onInit();
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
