import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/main_page.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void signIn() {
    // Navigate to Main shell
    Get.offAll(() => const MainPage());
  }
}
