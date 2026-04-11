import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/export_medication_list_controller.dart';
import '../../main/main_page.dart';
import '../../main/main_controller.dart';

class ExportMedicationListPage extends StatelessWidget {
  const ExportMedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExportMedicationListController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Export Medication List',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildConnectedStatusBanner(),
              const SizedBox(height: 20),
              _buildReconciliationSummary(),
              const SizedBox(height: 24),
              const Text(
                'Primary Export',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => controller.isExported.value
                    ? _buildExportSuccessCard()
                    : _buildExportToEMRCard(controller),
              ),
              const SizedBox(height: 24),
              const Text(
                'Alternative Options',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildAlternativeOptionsRow(),
              const SizedBox(height: 24),
              _buildExportIncludesBox(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFF86EFAC).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.wifi, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 8),
          Text(
            'Connected to EMR system',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reconciliation Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Patient', 'Margaret Thompson', isValueBold: false),
          const SizedBox(height: 12),
          _buildSummaryRow('MRN', 'MRN-45678', isValueBold: false),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Reconciled by',
            'Dr. Sarah Johnson, PharmD',
            isValueBold: false,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Date/Time',
            'Feb 8, 2026 at 2:45 PM',
            isValueBold: false,
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Active Medications',
            '8 medications',
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Interchanges Accepted',
            '3',
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Estimated Savings',
            '\$270/month',
            valueColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isValueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? const Color(0xFF334155),
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildExportSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
          SizedBox(height: 16),
          Text(
            'Successfully exported to EMR',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportToEMRCard(ExportMedicationListController controller) {
    return GestureDetector(
      onTap: () => controller.exportToEMR(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF38B6FF), Color(0xFF0C3064)],
            begin: Alignment(-0.8, -0.6), // Approximate angle of 106.24deg
            end: Alignment(0.8, 0.6),
            stops: [0.0164, 0.467], // 1.64% and 46.7%
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Export to EMR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sync directly to patient record',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeOptionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            Icons.description_outlined,
            'Generate PDF',
            const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            Icons.content_copy_outlined,
            'Copy List',
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            Icons.share_outlined,
            'Share',
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExportIncludesBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Includes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('Complete medication list with dosages'),
          const SizedBox(height: 8),
          _buildBulletPoint('All therapeutic interchanges and rationales'),
          const SizedBox(height: 8),
          _buildBulletPoint('Documented decline/discontinuation reasons'),
          const SizedBox(height: 8),
          _buildBulletPoint('Cost savings calculations'),
          const SizedBox(height: 8),
          _buildBulletPoint('Clinician signature and timestamp'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0),
          child: CircleAvatar(backgroundColor: Color(0xFF3B82F6), radius: 2.5),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2563EB),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
