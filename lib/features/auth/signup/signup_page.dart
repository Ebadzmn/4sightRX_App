import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import 'signup_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SignupController>()
        ? Get.find<SignupController>()
        : Get.put(SignupController(), permanent: true);
    controller.resetForm();
    controller.fetchOrganizations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, bottomInset + 24.0),
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
                          'Create your account',
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
                    label: 'First Name',
                    hint: 'John',
                    controller: controller.firstNameController,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'First Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Last Name',
                    hint: 'Doe',
                    controller: controller.lastNameController,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Last Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildOrganizationField(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email',
                    hint: 'name@email.com',
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
                      controller: controller.passwordController,
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
                      obscureText: !controller.isPasswordVisible.value,
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
                      isPassword: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => _buildTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: controller.confirmPasswordController,
                      validator: (value) {
                        final text = value ?? '';
                        if (text.isEmpty) {
                          return 'Confirm Password is required';
                        }
                        if (text != controller.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
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
                      isPassword: true,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.signUp(_formKey),
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
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    child: const Text(
                      'Already have an account? Login',
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

  Widget _buildOrganizationField() {
    return Obx(() {
      final status = controller.organizationLoadStatus.value;
      final organizations = controller.organizations;

      if (status == OrganizationLoadStatus.loading) {
        return _buildStatusField(
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading organizations...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        );
      }

      if (status == OrganizationLoadStatus.error) {
        return _buildStatusField(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Unable to load organizations',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => controller.fetchOrganizations(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (status == OrganizationLoadStatus.empty || organizations.isEmpty) {
        return _buildStatusField(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'No organizations available',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => controller.fetchOrganizations(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Organization ID',
              style: TextStyle(
                color: Color(0xFF677788),
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
          DropdownButtonFormField<String>(
            initialValue: controller.selectedOrganizationId.value.isEmpty
                ? null
                : controller.selectedOrganizationId.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Organization ID is required';
              }
              return null;
            },
            onChanged: (value) {
              controller.selectedOrganizationId.value = value ?? '';
            },
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
            isExpanded: true,
            decoration: _inputDecoration(hint: 'Select organization'),
            items: organizations
                .map(
                  (organization) => DropdownMenuItem<String>(
                    value: organization.id,
                    child: Text(
                      organization.name,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      );
    });
  }

  Widget _buildStatusField({required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Organization ID',
            style: TextStyle(
              color: Color(0xFF677788),
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
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FormFieldValidator<String>? validator,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF677788),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
          style: const TextStyle(color: Colors.black),
          cursorColor: const Color(0xFF0D477D),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      isDense: false,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
      counterText: '',
      alignLabelWithHint: false,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
