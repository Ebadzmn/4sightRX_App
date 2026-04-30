import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle('Privacy Policy for 4SightRx'),
              const SizedBox(height: 8),
              _buildParagraph('**Effective Date:** January 1, 2026'),
              const SizedBox(height: 16),
              _buildParagraph('4SightRx ("we", "our", or "us") respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our mobile application.'),
              const SizedBox(height: 24),

              _buildSectionTitle('1. Information We Collect'),
              _buildParagraph('We may collect the following types of information:'),
              const SizedBox(height: 8),
              _buildSubsectionTitle('a. Personal Information'),
              _buildBullet('Name'),
              _buildBullet('Email address'),
              const SizedBox(height: 8),
              _buildSubsectionTitle('b. Health Information'),
              _buildBullet('User-uploaded prescription data (images, text, or documents)'),
              const SizedBox(height: 8),
              _buildSubsectionTitle('c. User Content'),
              _buildBullet('Files and documents you upload within the app (such as prescriptions)'),
              const SizedBox(height: 8),
              _buildSubsectionTitle('d. Usage & Diagnostics (if applicable)'),
              _buildBullet('App usage data (e.g., interactions, features used)'),
              _buildBullet('Crash logs and performance data'),
              const SizedBox(height: 24),

              _buildSectionTitle('2. How We Use Your Information'),
              _buildParagraph('We use the collected data to:'),
              _buildBullet('Create and manage your account'),
              _buildBullet('Analyze prescriptions using AI'),
              _buildBullet('Provide insights based on your uploaded data'),
              _buildBullet('Improve app performance and user experience'),
              _buildBullet('Ensure security and prevent misuse'),
              const SizedBox(height: 24),

              _buildSectionTitle('3. Data Sharing'),
              _buildParagraph('We do **not sell or rent** your personal or health data.'),
              const SizedBox(height: 8),
              _buildParagraph('We may share data only in the following cases:'),
              _buildBullet('With trusted service providers (e.g., cloud storage or analytics tools)'),
              _buildBullet('When required by law or legal process'),
              _buildBullet('To protect our rights and prevent fraud or abuse'),
              const SizedBox(height: 24),

              _buildSectionTitle('4. Data Security'),
              _buildParagraph('We implement appropriate technical and organizational measures to protect your data. However, no system is completely secure, and we cannot guarantee absolute security.'),
              const SizedBox(height: 24),

              _buildSectionTitle('5. Data Retention'),
              _buildParagraph('We retain your data only for as long as necessary to provide our services or comply with legal obligations.'),
              const SizedBox(height: 24),

              _buildSectionTitle('6. Your Rights'),
              _buildParagraph('You may:'),
              _buildBullet('Access or update your account information'),
              _buildBullet('Request deletion of your data'),
              _buildBullet('Stop using the app at any time'),
              const SizedBox(height: 8),
              _buildParagraph('To make a request, contact us at the email below.'),
              const SizedBox(height: 24),

              _buildSectionTitle('7. Children’s Privacy'),
              _buildParagraph('4SightRx is not intended for children under the age of 13. We do not knowingly collect personal data from children.'),
              const SizedBox(height: 24),

              _buildSectionTitle('8. Medical Disclaimer'),
              _buildParagraph('4SightRx provides informational insights only and does not offer medical advice. Always consult a licensed healthcare professional before making any medical decisions.'),
              const SizedBox(height: 24),

              _buildSectionTitle('9. Changes to This Policy'),
              _buildParagraph('We may update this Privacy Policy from time to time. Changes will be posted within the app or on our website.'),
              const SizedBox(height: 24),

              _buildSectionTitle('10. Contact Us'),
              _buildParagraph('If you have any questions about this Privacy Policy, please contact us:'),
              const SizedBox(height: 8),
              _buildParagraph('Email: support@4sightrx.com', isLink: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isLink = false}) {
    List<TextSpan> spans = [];
    if (text.contains('**')) {
      final parts = text.split('**');
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1) {
          spans.add(TextSpan(
            text: parts[i],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ));
        } else {
          spans.add(TextSpan(text: parts[i]));
        }
      }
    } else {
      spans.add(TextSpan(text: text));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isLink ? const Color(0xFF0F62FE) : const Color(0xFF475569),
            fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
          ),
          children: spans,
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 12.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
