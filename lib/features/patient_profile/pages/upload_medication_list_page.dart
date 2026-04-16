import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/medication_ocr_controller.dart';
import 'document_processing_page.dart';

class UploadMedicationListPage extends StatelessWidget {
  const UploadMedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicationOcrController controller = Get.put(
      MedicationOcrController(),
    );
    final patientId = _resolvePatientId();
    if (patientId.isNotEmpty && controller.patientId.value != patientId) {
      controller.configureForPatient(patientId);
    }

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
                  Obx(() {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showSourcePicker(controller),
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
                          child: Text(
                            controller.hasSelectedFile
                                ? 'Change File'
                                : 'Choose File',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (controller.hasSelectedFile) ...[
                          const SizedBox(height: 16),
                          _buildFilePreview(controller),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    Get.to(
                                      () => const DocumentProcessingPage(),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38B6FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Extract Medications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (controller.errorMessage.value.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildErrorBanner(controller.errorMessage.value),
                        ],
                      ],
                    );
                  }),
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

  Future<void> _showSourcePicker(MedicationOcrController controller) async {
    await Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.image_outlined,
                color: Color(0xFF0C3064),
              ),
              title: const Text('Pick Image from Gallery'),
              onTap: () async {
                Get.back();
                await controller.pickImageFromGallery();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Color(0xFF0C3064),
              ),
              title: const Text('Pick PDF Document'),
              onTap: () async {
                Get.back();
                await controller.pickPdfDocument();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilePreview(MedicationOcrController controller) {
    return Obx(() {
      final fileName = controller.selectedFileName.value;
      final fileType = controller.selectedFileType.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                fileType == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                color: const Color(0xFF0C3064),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected file',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileType,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 13,
          fontWeight: FontWeight.w500,
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

  String _resolvePatientId() {
    final arguments = Get.arguments;
    if (arguments is Map) {
      return arguments['patientId']?.toString().trim() ?? '';
    }

    return '';
  }
}
