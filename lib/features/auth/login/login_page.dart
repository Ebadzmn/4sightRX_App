import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../forgot_password/forgot_password_page.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      controller.emailController.clear();
      controller.passwordController.clear();

      final arguments = Get.arguments;
      if (arguments is Map && arguments['email'] != null) {
        controller.emailController.text = arguments['email'].toString();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 88),
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/spLogo.png', width: 200),
                        const SizedBox(height: 10),
                        const Text(
                          'Formulary Management Solution',
                          style: TextStyle(
                            color: Color(0xFF677788),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    label: 'Email',
                    hint: 'name@email.com',
                    prefixIcon: Icons.email_outlined,
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
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => _buildTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      controller: controller.passwordController,
                      isPassword: true,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: (value) {
                        final text = value ?? '';
                        if (text.isEmpty) {
                          return 'Password is required';
                        }
                        if (text.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.isPasswordVisible.value =
                              !controller.isPasswordVisible.value;
                        },
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.login(_formKey),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D477D),
                              disabledBackgroundColor: const Color(
                                0xFF0D477D,
                              ).withValues(alpha: 0.55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        if (controller.canLoginWithBiometric.value) ...[
                          const SizedBox(height: 20),
                          IconButton(
                            onPressed: controller.biometricLogin,
                            icon: const Icon(
                              Icons.fingerprint,
                              size: 48,
                              color: Color(0xFF0D477D),
                            ),
                            tooltip: 'Login with Biometrics',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const ForgotPasswordPage());
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Color(0xFF2196F3), fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signup),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Color(0xFF2196F3), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Secure 4sightRX medication reconciliation',
                    style: TextStyle(color: Color(0xFF677788), fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '© 2026 4sightRX. All rights reserved.',
                    style: TextStyle(color: Color(0xFF677788), fontSize: 10),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FormFieldValidator<String>? validator,
    bool isRequired = false,
    bool isPassword = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF677788),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade400)
                : null,
            suffixIcon: suffixIcon,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0D477D)),
            ),
          ),
        ),
      ],
    );
  }
}
