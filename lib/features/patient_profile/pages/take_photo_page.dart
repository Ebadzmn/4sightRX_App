import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/medication_ocr_controller.dart';
import 'document_processing_page.dart';

class TakePhotoPage extends StatelessWidget {
  const TakePhotoPage({super.key});

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
                color: const Color(0xFF162032),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                if (controller.hasSelectedFile) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        controller.selectedFile.value!,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
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
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white.withOpacity(0.2),
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
          Obx(() {
            if (!controller.hasSelectedFile) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await controller.captureImageFromCamera();
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3064),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C3064).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
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
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () async {
                      await controller.pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick from Gallery'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await controller.captureImageFromCamera();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retake'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await controller.pickImageFromGallery();
                          },
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            Get.to(() => const DocumentProcessingPage());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38B6FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 4,
                      shadowColor: const Color(0xFF38B6FF).withOpacity(0.4),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Extract Medications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (controller.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildErrorBanner(controller.errorMessage.value),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildFilePreview(MedicationOcrController controller) {
    return Obx(() {
      final fileName = controller.selectedFileName.value;
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
              child: const Icon(Icons.image_outlined, color: Color(0xFF0C3064)),
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
