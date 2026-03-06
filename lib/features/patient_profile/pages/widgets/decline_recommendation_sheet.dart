import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/formulary_comparison_controller.dart';
import 'recommendation_declined_dialog.dart';

class DeclineRecommendationController extends GetxController {
  final RxString selectedReason = ''.obs;
  final TextEditingController otherDetailsController = TextEditingController();
  final RxString otherDetails = ''.obs;
  final RxBool isOtherSelected = false.obs;

  void selectReason(String reason) {
    selectedReason.value = reason;
    isOtherSelected.value = reason == 'Other (please specify)';
  }

  void updateOtherDetails(String value) {
    otherDetails.value = value;
  }

  @override
  void onClose() {
    otherDetailsController.dispose();
    super.onClose();
  }
}

class DeclineRecommendationSheet extends StatelessWidget {
  final FormularyItem item;
  DeclineRecommendationSheet({super.key, required this.item});

  final reasons = [
    'Patient allergy or intolerance',
    'Clinical contraindication (e.g., renal impairment)',
    'Patient/family preference or refusal',
    'No therapeutic equivalence',
    'Cost or insurance issue',
    'Other (please specify)',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeclineRecommendationController());

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Decline Recommendation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Why are you declining this formulary\nsuggestion?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFF1F5F9), height: 1),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Declining interchange for ',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: item.currentName,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Select reason *',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),

                  const SizedBox(height: 12),

                  // Reasons List
                  Obx(
                    () => Column(
                      children: reasons.map((reason) {
                        final isSelected =
                            controller.selectedReason.value == reason;
                        return GestureDetector(
                          onTap: () => controller.selectReason(reason),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFFCBD5E1),
                                      width: isSelected ? 6 : 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Other Details Field
                  Obx(() {
                    if (controller.isOtherSelected.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Additional notes/reason ',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller.otherDetailsController,
                            onChanged: controller.updateOtherDetails,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Enter details here...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.transparent),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() {
                          final canConfirm =
                              controller.selectedReason.isNotEmpty &&
                              (!controller.isOtherSelected.value ||
                                  controller.otherDetails.isNotEmpty);

                          return ElevatedButton(
                            onPressed: canConfirm
                                ? () {
                                    Get.back(); // Close bottom sheet
                                    Get.dialog(
                                      const RecommendationDeclinedDialog(),
                                    );
                                    // Auto close dialog after 2 seconds
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (Get.isDialogOpen ?? false) {
                                          Get.back();
                                        }
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: canConfirm
                                  ? const Color(0xFF0C4A6E) // Dark navy
                                  : const Color(0xFFE2E8F0), // Light grey
                              foregroundColor: canConfirm
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirm Decline',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
