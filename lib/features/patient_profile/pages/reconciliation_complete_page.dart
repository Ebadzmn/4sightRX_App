import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reconciliation_complete_controller.dart';
import 'export_medication_list_page.dart';
import '../../main/main_page.dart';
import '../../main/main_controller.dart';

class ReconciliationCompletePage extends StatelessWidget {
  const ReconciliationCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReconciliationCompleteController());
    controller.ensureLoaded(Get.arguments);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1, // Patients tab
        onTap: (index) {
          if (index == 1) return;
          final mainController = Get.put(MainController());
          mainController.changeTabIndex(index);
          Get.offAll(() => const MainPage());
        },
        selectedItemColor: const Color(0xFF0F62FE),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Reconciliation Complete',
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
      body: Obx(() {
        final hasError = controller.errorMessage.value.isNotEmpty &&
            controller.continuedMedications.isEmpty &&
            controller.changedMedications.isEmpty &&
            controller.discontinuedMedications.isEmpty;

        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (hasError) {
          return _buildErrorState(controller);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStepper(),
              const SizedBox(height: 20),
              _buildSuccessBanner(controller),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Updated Medication List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Review final medication list before export',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Continued Medications (${controller.continuedMedications.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (controller.continuedMedications.isEmpty)
                      _buildEmptySectionMessage('No continued medications')
                    else
                      ...List.generate(
                        controller.continuedMedications.length,
                        (index) => _buildMedicationCard(
                          controller.continuedMedications[index],
                          index,
                          controller,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Changed Medications (${controller.changedMedications.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (controller.changedMedications.isEmpty)
                      _buildEmptySectionMessage('No changed medications')
                    else
                      ...List.generate(
                        controller.changedMedications.length,
                        (index) => _buildChangedMedicationCard(
                          context,
                          controller.changedMedications[index],
                          index,
                          controller,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Discontinued/Deprescribed Medications (${controller.discontinuedMedications.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (controller.discontinuedMedications.isEmpty)
                      _buildEmptySectionMessage('No discontinued medications')
                    else
                      ...List.generate(
                        controller.discontinuedMedications.length,
                        (index) => _buildDiscontinuedMedicationCard(
                          controller.discontinuedMedications[index],
                        ),
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const ExportMedicationListPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4A6E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm Update Medication List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildExportSection(),
                    const SizedBox(height: 24),
                    _buildReconciliationDetailsBox(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Medication List',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildExportButton(
                Icons.file_download_outlined,
                'Export EMR',
                true,
              ),
              const SizedBox(width: 12),
              _buildExportButton(Icons.copy_outlined, 'Copy Text', false),
              const SizedBox(width: 12),
              _buildExportButton(Icons.share_outlined, 'Share PDF', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(IconData icon, String label, bool isPrimary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0C4A6E) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : const Color(0xFF475569),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isPrimary ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationDetailsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reconciliation Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Reconciled by:', 'Dr. Sarah Johnson, PharmD'),
          const SizedBox(height: 8),
          _buildDetailRow('Date/Time:', 'Feb 6, 2026 at 2:45 PM'),
          const SizedBox(height: 8),
          _buildDetailRow('Patient:', 'Margaret Thompson (MRN-45678)'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E40AF)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E40AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangedMedicationCard(
    BuildContext context,
    ChangedMedicationItem item,
    int index,
    ReconciliationCompleteController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF), // Light blue
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.52,
                    ),
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Changed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (item.actionDisplayLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _actionBadgeBackground(item.actionDisplayLabel),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _actionBadgeBorder(item.actionDisplayLabel),
                        ),
                      ),
                      child: Text(
                        item.actionDisplayLabel,
                        style: TextStyle(
                          color: _actionBadgeForeground(item.actionDisplayLabel),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.dosageInfo,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      item.oldMedName,
                      textAlign: TextAlign.right,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.frequency.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.frequency,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Covered: ',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    TextSpan(
                      text: item.hospiceLabel,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => controller.toggleChangedHospice(index),
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
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            right: 0,
            top: 2,
            child: Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscontinuedMedicationCard(DiscontinuedMedicationItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          if (item.dosage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.dosage,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
          if (item.frequency.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.frequency,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.reason,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text(
              'Loading reconciliation summary...',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ReconciliationCompleteController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCEE0FF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'Failed to load reconciliation summary',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.retrySummary,
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
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem('Upload', true),
          _buildStepDivider(),
          _buildStepItem('Review', true),
          _buildStepDivider(),
          _buildStepItem('Formulary', true),
          _buildStepDivider(),
          _buildStepItem('Finalize', true),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F62FE),
            border: Border.all(color: const Color(0xFF0F62FE), width: 1.5),
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 1.5,
        color: const Color(0xFF0F62FE),
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildSuccessBanner(ReconciliationCompleteController controller) {
    final activeCount =
        controller.continuedMedications.length + controller.changedMedications.length;
    final changesCount = controller.changedMedications.length;
    final savingsValue =
        controller.totalSavings.value.isNotEmpty ? controller.totalSavings.value : '\$0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF38B6FF), Color(0xFF0C3064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Reconciliation\nComplete!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Ready to update patient record',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('$activeCount', 'Active Meds'),
              _buildStatItem('$changesCount', 'Changes'),
              _buildStatItem(savingsValue, 'Monthly Savings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
    FinalMedicationItem item,
    int index,
    ReconciliationCompleteController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Very light green
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (item.dosage.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.dosage,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
              if (item.frequency.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.frequency,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => controller.toggleContinuedHospice(index),
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
                    Obx(
                      () => Text(
                        item.isHospiceCovered.value ? 'Yes' : 'No',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _actionBadgeBackground(String actionLabel) {
    switch (actionLabel.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFEFF6FF);
      case 'declined':
        return const Color(0xFFFEF2F2);
      case 'd/c':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  Color _actionBadgeBorder(String actionLabel) {
    switch (actionLabel.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFBFDBFE);
      case 'declined':
        return const Color(0xFFFECACA);
      case 'd/c':
        return const Color(0xFFFED7AA);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  Color _actionBadgeForeground(String actionLabel) {
    switch (actionLabel.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF1D4ED8);
      case 'declined':
        return const Color(0xFFB91C1C);
      case 'd/c':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF475569);
    }
  }
}
