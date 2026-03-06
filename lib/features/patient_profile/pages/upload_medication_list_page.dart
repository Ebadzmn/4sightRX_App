import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'document_processing_page.dart';

class UploadMedicationListPage extends StatelessWidget {
  const UploadMedicationListPage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Indicator Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProgressIndicator(),
            ),
            const SizedBox(height: 24),
            // Main Upload Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upload_rounded,
                    size: 80,
                    color: Color(0xFFA0AEC0), // Light slate color like image
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select a PDF or image file of\nthe medication list',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => const DocumentProcessingPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3064),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Choose File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Footer text
            Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF64748B),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Supported formats: PDF, JPG, PNG'),
                ),
              ),
            ),
          ],
        ),
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
