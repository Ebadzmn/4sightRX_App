import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_medication_controller.dart';
import 'formulary_comparison_page.dart';

class ReviewMedicationPage extends StatelessWidget {
  const ReviewMedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewMedicationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Review Medication',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStepper(),
            const SizedBox(height: 16),
            _buildSummaryBanner(),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: List.generate(
                  controller.medications.length,
                  (index) => _buildMedicationCard(
                    controller.medications[index],
                    () => controller.deleteMedication(index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Add Missing Medication Button
            OutlinedButton(
              onPressed: () {
                // Action for adding missing medication
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(
                  color: Color(0xFF1E3A8A),
                ), // Dark blue border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF64748B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add Missing Medication',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FB),
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const FormularyComparisonPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4A6E), // Dark navy blue
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Formulary Check',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning, color: Color(0xFFD97706), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Please review highlighted medications before continuing',
                    style: TextStyle(color: Color(0xFFD97706), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem('Upload', true, true),
          _buildStepDivider(true),
          _buildStepItem('Review', true, false),
          _buildStepDivider(false),
          _buildStepItem('Formulary', false, false),
          _buildStepDivider(false),
          _buildStepItem('Finalize', false, false),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, bool isCompleted, bool isPast) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? const Color(0xFF0F62FE) : Colors.white,
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF0F62FE)
                  : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isPast ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: isCompleted && !isPast
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: isCompleted ? const Color(0xFF0F62FE) : const Color(0xFFCBD5E1),
        margin: const EdgeInsets.only(bottom: 24), // Center align with circles
      ),
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '8 medications extracted',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text(
                '1 need review',
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Please review the extracted medications and make any necessary corrections',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationItem item, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.needsReview ? const Color(0xFFFEFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.needsReview
              ? const Color(0xFFFCD34D)
              : const Color(0xFFCEE0FF),
          width: 1.5,
        ),
        boxShadow: [
          if (!item.needsReview)
            BoxShadow(
              color: const Color(0xFF0F62FE).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (item.needsReview) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.dosage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.frequency,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (item.instructions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.instructions,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // Edit action - placeholder
                },
                icon: const Icon(
                  Icons.mode_edit_outline_outlined,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF64748B),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
