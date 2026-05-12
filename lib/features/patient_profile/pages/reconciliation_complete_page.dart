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
        currentIndex: 1,
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
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoadingState();

        final hasError =
            controller.errorMessage.value.isNotEmpty &&
            controller.continuedMedications.isEmpty &&
            controller.discontinuedMedications.isEmpty &&
            controller.declinedMedications.isEmpty;

        if (hasError) return _buildErrorState(controller);

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

                    // ── Continued Medications ──
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Continued meds',
                      controller.continuedMedications.length,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    if (controller.continuedMedications.isEmpty)
                      _buildEmptyMessage('No continued medications')
                    else
                      ...controller.continuedMedications.map(
                        (item) => _buildMedicationCard(
                          context,
                          item,
                          const Color(0xFFF0FDF4),
                          const Color(0xFFDCFCE7),
                          const Color(0xFF10B981),
                          'Continued',
                        ),
                      ),

                    // ── Discontinued Medications ──
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Discontinued meds',
                      controller.discontinuedMedications.length,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),
                    if (controller.discontinuedMedications.isEmpty)
                      _buildEmptyMessage('No discontinued medications')
                    else
                      ...controller.discontinuedMedications.map(
                        (item) => _buildMedicationCard(
                          context,
                          item,
                          const Color(0xFFFFFBEB),
                          const Color(0xFFFDE68A),
                          const Color(0xFFF59E0B),
                          'Discontinued',
                        ),
                      ),

                    // ── Declined Medications ──
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Changed meds',
                      controller.declinedMedications.length,
                      const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 12),
                    if (controller.declinedMedications.isEmpty)
                      _buildEmptyMessage('No declined medications')
                    else
                      ...controller.declinedMedications.map(
                        (item) => _buildMedicationCard(
                          context,
                          item,
                          const Color(0xFFFEF2F2),
                          const Color(0xFFFECACA),
                          const Color(0xFFEF4444),
                          'Declined',
                        ),
                      ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () =>
                          Get.to(() => const ExportMedicationListPage()),
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
                        'Confirm & Export Medication List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildExportSection(controller),
                    const SizedBox(height: 24),
                    _buildPatientInfoBox(controller),
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

  // ── Section Title ──
  Widget _sectionTitle(String title, int count, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ── Medication Card ──
  Widget _buildMedicationCard(
    BuildContext context,
    ReconciliationMedicationItem item,
    Color bgColor,
    Color borderColor,
    Color accentColor,
    String badgeLabel,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: medication name + badges
          Row(
            children: [
              Expanded(
                child: Text(
                  item.currentMedication,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _badge(
                badgeLabel,
                accentColor.withValues(alpha: 0.15),
                accentColor,
              ),
              if (item.actionDisplayLabel.isNotEmpty) ...[
                const SizedBox(width: 6),
                _badge(
                  item.actionDisplayLabel,
                  _actionBg(item.actionDisplayLabel),
                  _actionFg(item.actionDisplayLabel),
                ),
              ],
            ],
          ),

          // Recommended medication
          if (item.recommendedMedication.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.recommendedMedication,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Rationale
          if (item.rationale.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.rationale,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Bottom row: savings + hospice
          Row(
            children: [
              if (item.savingsText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Savings: ${item.savingsText}',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (item.savingsText.isNotEmpty) const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.isHospiceCovered.value
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isHospiceCovered.value
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isHospiceCovered.value
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 14,
                      color: item.isHospiceCovered.value
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hospice: ${item.hospiceLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: item.isHospiceCovered.value
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Success Banner ──
  Widget _buildSuccessBanner(ReconciliationCompleteController controller) {
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
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatItem(
                  '${controller.totalMedications}',
                  'Total Meds',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '${controller.continuedMedications.length}',
                  'Continued',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  controller.savingsText,
                  'Monthly Savings',
                ),
              ),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // ── Stepper ──
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
          _stepItem('Upload', true),
          _stepDivider(),
          _stepItem('Review', true),
          _stepDivider(),
          _stepItem('Formulary', true),
          _stepDivider(),
          _stepItem('Finalize', true),
        ],
      ),
    );
  }

  Widget _stepItem(String title, bool done) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0F62FE),
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 1.5,
        color: const Color(0xFF0F62FE),
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  // ── Export Section ──
  Widget _buildExportSection(ReconciliationCompleteController controller) {
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
          Obx(
            () => Row(
              children: [
                _buildExportButton(
                  icon: Icons.file_download_outlined,
                  label: controller.isDownloading.value
                      ? 'Downloading...'
                      : 'Export EMR',
                  isPrimary: true,
                  isLoading: controller.isDownloading.value,
                  onTap: controller.isDownloading.value
                      ? null
                      : () => controller.downloadAndOpenPdf(),
                ),
                const SizedBox(width: 12),
                _buildExportButton(
                  icon: Icons.share_outlined,
                  label: controller.isSharing.value
                      ? 'Sharing...'
                      : 'Share PDF',
                  isPrimary: false,
                  isLoading: controller.isSharing.value,
                  onTap: controller.isSharing.value
                      ? null
                      : () => controller.sharePdf(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF0C4A6E)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? Colors.white : const Color(0xFF475569),
                  ),
                )
              else
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
      ),
    );
  }

  // ── Patient Info Box ──
  Widget _buildPatientInfoBox(ReconciliationCompleteController controller) {
    final patient = controller.patientInfo.value;
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
            'Patient Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 16),
          if (patient != null) ...[
            _detailRow('Patient:', patient.fullName),
            const SizedBox(height: 8),
            _detailRow('MRN:', patient.mrn),
            const SizedBox(height: 8),
            _detailRow('DOB:', patient.dateOfBirth),
            const SizedBox(height: 8),
            _detailRow('Sex:', patient.gender),
            const SizedBox(height: 8),
            _detailRow('Phone:', patient.phoneNumber),
            const SizedBox(height: 8),
            _detailRow('Allergies:', patient.medicationAllergies),
          ] else ...[
            const Text(
              'Patient information not available',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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

  // ── Helper widgets ──
  Widget _buildEmptyMessage(String message) {
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
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
              const Icon(
                Icons.error_outline,
                color: Color(0xFFEF4444),
                size: 28,
              ),
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

  // ── Action badge colors ──
  Color _actionBg(String label) {
    switch (label.toLowerCase()) {
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

  Color _actionFg(String label) {
    switch (label.toLowerCase()) {
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
