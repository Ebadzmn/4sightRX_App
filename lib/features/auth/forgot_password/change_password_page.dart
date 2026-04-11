import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'change_password_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final ChangePasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ChangePasswordController>()
        ? Get.find<ChangePasswordController>()
        : Get.put(ChangePasswordController(), permanent: true);
    final arguments = Get.arguments;
    if (arguments is Map && arguments['email'] != null) {
      controller.email = arguments['email'].toString();
    }
    controller.newPasswordController.clear();
    controller.confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a new password',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For ${controller.email}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildPasswordLabel('New Password', required: true),
              const SizedBox(height: 8),
              Obx(
                () => _buildPasswordField(
                  controller: controller.newPasswordController,
                  hint: 'Enter new password',
                  obscureText: !controller.isNewPasswordVisible.value,
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.isNewPasswordVisible.value =
                          !controller.isNewPasswordVisible.value;
                    },
                    icon: Icon(
                      controller.isNewPasswordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordLabel('Confirm Password', required: true),
              const SizedBox(height: 8),
              Obx(
                () => _buildPasswordField(
                  controller: controller.confirmPasswordController,
                  hint: 'Confirm password',
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.isConfirmPasswordVisible.value =
                          !controller.isConfirmPasswordVisible.value;
                    },
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4A6E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF0C4A6E).withOpacity(0.55),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordLabel(String label, {bool required = false}) {
    if (!required) {
      return Text(
        label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade400,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFF0D477D)),
        ),
      ),
    );
  }
}