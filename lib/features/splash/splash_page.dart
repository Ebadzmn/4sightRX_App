import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/spLogo.png', width: 250),
                  const SizedBox(height: 20),
                  const Text(
                    'Medication Management System',
                    style: TextStyle(
                      color: Color(0xFF677788),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              children: const [
                Text(
                  'Secure 4sightRX medication reconciliation',
                  style: TextStyle(color: Color(0xFF677788), fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  '© 2026 4sightRX. All rights reserved.',
                  style: TextStyle(color: Color(0xFF677788), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
