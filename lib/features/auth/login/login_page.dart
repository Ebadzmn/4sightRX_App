import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../forgot_password/forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/spLogo.png', width: 200),
                    const SizedBox(height: 10),
                    const Text(
                      'Medication Management System',
                      style: TextStyle(color: Color(0xFF677788), fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                label: 'Email',
                hint: 'nurse@hospital.com',
                prefixIcon: Icons.email_outlined,
                controller: controller.emailController,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Full Name',
                hint: '',
                controller: controller.fullNameController,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Password',
                hint: '........',
                prefixIcon: Icons.lock_outline,
                controller: controller.passwordController,
                isRequired: true,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D477D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fingerprint, color: Color(0xFF677788)),
                  label: const Text(
                    'Use Biometric Login',
                    style: TextStyle(fontSize: 16, color: Color(0xFF677788)),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
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
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    bool isPassword = false,
    IconData? prefixIcon,
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
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade400)
                : null,
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
