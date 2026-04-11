import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ForgotPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ForgotPasswordController>()
        ? Get.find<ForgotPasswordController>()
        : Get.put(ForgotPasswordController(), permanent: true);
    controller.emailController.clear();
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
          'Forgot Password',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter your email address and we\'ll send\nyou instructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Email Address',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(text)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'your.email@hospital.com',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey.shade400,
                        ),
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.forgotPassword(_formKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D477D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor:
                            const Color(0xFF0D477D).withOpacity(0.55),
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
                              'Send Reset Instructions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD0E5FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need help?',
                        style: TextStyle(
                          color: Color(0xFF0055BB),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: const TextSpan(
                          text:
                              'Contact your facility\'s IT support or\nsystem administrator for assistance.',
                          style: TextStyle(
                            color: Color(0xFF0055BB),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
