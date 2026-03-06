import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/document_processing_controller.dart';

class DocumentProcessingPage extends StatelessWidget {
  const DocumentProcessingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DocumentProcessingController controller = Get.put(
      DocumentProcessingController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF1F5F9), // Light grey border
                  width: 4.0,
                ),
              ),
              child: Center(
                child: Obx(
                  () => Text(
                    '${controller.progress.value}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2563EB), // Blue color
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Processing Document',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B), // Dark slate
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Extracting medication information...',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B), // Slate gray
              ),
            ),
            const SizedBox(height: 40),
            // Progress Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepItem(
                      'OCR scanning complete',
                      controller.currentStepIndex.value >= 0,
                      controller.currentStepIndex.value > 0,
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      'Identifying medications',
                      controller.currentStepIndex.value >= 1,
                      controller.currentStepIndex.value > 1,
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      'Extracting dosage information',
                      controller.currentStepIndex.value >= 2,
                      controller.currentStepIndex.value > 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String text, bool isActive, bool isCompleted) {
    // Determine color based on state. Design shows green dot for active/completed,
    // and grey for inactive.
    Color dotColor = const Color(0xFFE2E8F0); // Default inactive light grey
    if (isActive || isCompleted) {
      dotColor = const Color(0xFF10B981); // Green color
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF94A3B8), // Slate gray for the text
          ),
        ),
      ],
    );
  }
}
