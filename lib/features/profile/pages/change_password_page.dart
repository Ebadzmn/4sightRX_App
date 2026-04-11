import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

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
          'Change Password',
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
                'Update your password',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For security, enter your current password and choose a new one.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildPasswordLabel('Current Password'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: controller.currentPasswordController,
                hint: 'Enter current password',
              ),
              const SizedBox(height: 20),
              _buildPasswordLabel('New Password', required: true),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: controller.newPasswordController,
                hint: 'Enter new password',
              ),
              const SizedBox(height: 20),
              _buildPasswordLabel('Confirm New Password', required: true),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: controller.confirmPasswordController,
                hint: 'Re-enter new password',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4A6E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(
          Icons.lock_outline,
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
    );
  }
}

