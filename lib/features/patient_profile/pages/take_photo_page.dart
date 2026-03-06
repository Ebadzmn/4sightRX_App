import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'document_processing_page.dart';

class TakePhotoPage extends StatelessWidget {
  const TakePhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Upload Medication List',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProgressIndicator(),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF162032), // Dark slate/navy color
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Position medication list within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Camera Button Section
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => const DocumentProcessingPage());
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C3064),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to capture',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Upload', 'Review', 'Formulary', 'Finalize'];
    const activeColor = Color(0xFF2563EB); // Blue
    const inactiveColor = Color(0xFFCBD5E1); // Gray
    const activeIndex = 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 == 1) {
          // Connecting Line
          final stepIndex = index ~/ 2;
          final isLineActive = stepIndex < activeIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: 12,
              ), // align with center of circle
              height: 1.5,
              color: isLineActive ? activeColor : inactiveColor,
            ),
          );
        } else {
          // Circle and Text
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == activeIndex;
          final isCompleted = stepIndex < activeIndex;

          return SizedBox(
            width: 70, // approximate width to encompass text
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isCompleted ? activeColor : Colors.white,
                    border: Border.all(
                      color: isActive || isCompleted
                          ? activeColor
                          : inactiveColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted || isActive
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: inactiveColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[stepIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8), // gray text for all in image
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
