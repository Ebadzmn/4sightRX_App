import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/processing_complete_controller.dart';

class ProcessingCompletePage extends StatelessWidget {
  const ProcessingCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(ProcessingCompleteController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981), // Green color
                  width: 4.0,
                ),
              ),
              child: const Center(
                child: Icon(Icons.check, color: Color(0xFF10B981), size: 48),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Processing Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B), // Dark slate
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            const Text(
              'Medications extracted successfully',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B), // Slate gray
              ),
            ),
          ],
        ),
      ),
    );
  }
}
