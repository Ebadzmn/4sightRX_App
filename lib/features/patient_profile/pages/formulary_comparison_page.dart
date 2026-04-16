import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/formulary_comparison_controller.dart';
import 'widgets/accept_recommendation_sheet.dart';
import 'widgets/decline_recommendation_sheet.dart';
import 'reconciliation_complete_page.dart';

class FormularyComparisonPage extends StatelessWidget {
  const FormularyComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<FormularyComparisonController>()
        ? Get.find<FormularyComparisonController>()
        : Get.put(FormularyComparisonController());
    controller.ensureLoaded(Get.arguments);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Formulary Comparison',
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
            _buildSummaryBanner(controller),
            const SizedBox(height: 16),
            Obx(
              () {
                if (controller.isAnalyzing.value) {
                  return _buildLoadingState();
                }

                if (controller.comparisons.isEmpty) {
                  return _buildErrorState(controller);
                }

                return Column(
                  children: List.generate(
                    controller.comparisons.length,
                    (index) => _buildComparisonCard(
                      controller.comparisons[index],
                      index,
                      controller,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF), // Light blue background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCEE0FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'About Therapeutic Interchanges',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "These recommendations are based on your facility's formulary and clinical guidelines. All suggested alternatives have equivalent therapeutic effects.",
                    style: TextStyle(
                      color: Color(0xFF0F62FE), // Blue text
                      fontSize: 13,
                      height: 1.4,
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
          child: Obx(() {
            final canContinue =
                !controller.isAnalyzing.value && controller.comparisons.isNotEmpty;

            return ElevatedButton(
              onPressed: canContinue
                  ? () {
                      Get.to(() => const ReconciliationCompletePage());
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4A6E), // Dark navy blue
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: const Color(0xFF0C4A6E).withOpacity(
                  0.4,
                ),
              ),
              child: Text(
                controller.isAnalyzing.value
                    ? 'Analyzing medications...'
                    : 'Continue to Final Review',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }),
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
          _buildStepItem('Review', true, true),
          _buildStepDivider(true),
          _buildStepItem('Formulary', true, false),
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
            color: isCompleted && isPast
                ? const Color(0xFF0F62FE)
                : Colors.white,
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF0F62FE)
                  : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: isCompleted && isPast
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF0F62FE)
                          : const Color(0xFFCBD5E1),
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
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildSummaryBanner(FormularyComparisonController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Formulary analysis complete',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review each recommendation & select an action',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 4),
          Obx(() {
            return Text(
              '${controller.comparisons.length} medications pending action',
              style: const TextStyle(color: Color(0xFF0F62FE), fontSize: 13),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCEE0FF)),
      ),
      child: Column(
        children: const [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing medications...',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we compare the selected medications.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FormularyComparisonController controller) {
    final message = controller.errorMessage.value.isNotEmpty
        ? controller.errorMessage.value
        : 'Failed to analyze medications';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCEE0FF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.retryAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4A6E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    FormularyItem item,
    int index,
    FormularyComparisonController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCEE0FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F62FE).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Split Section
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side: Current
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.currentName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.currentDosage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            item.currentDosage,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (item.currentFrequency.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.currentFrequency,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Divider
                Container(width: 1, color: const Color(0xFFCEE0FF)),
                // Right side: Recommended
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F8FF), // Light blue background
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Color(0xFF0F62FE),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.recommendedName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.recommendedDosage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            item.recommendedDosage,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (item.recommendedFrequency.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.recommendedFrequency,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xFFCEE0FF)),

          // Bottom Info & Actions Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning / Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.warningText,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Savings & Hospice Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5), // Light green
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item.savingsText,
                        style: const TextStyle(
                          color: Color(0xFF059669), // Emerald
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.toggleHospiceCoverage(index),
                      child: Row(
                        children: [
                          Obx(
                            () => Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: item.isHospiceCovered.value
                                    ? const Color(0xFF0F62FE)
                                    : Colors.white,
                                border: Border.all(
                                  color: item.isHospiceCovered.value
                                      ? const Color(0xFF0F62FE)
                                      : const Color(0xFF94A3B8),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: item.isHospiceCovered.value
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Hospice covered',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.bottomSheet(
                            AcceptRecommendationSheet(item: item),
                            isScrollControlled: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C4A6E), // Dark navy
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.bottomSheet(
                            DeclineRecommendationSheet(item: item),
                            isScrollControlled: true,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444), // Red
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white, // Red
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('D/C'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
