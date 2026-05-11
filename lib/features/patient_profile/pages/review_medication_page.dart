import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../controllers/medication_ocr_controller.dart';
import 'formulary_comparison_page.dart';
import 'add_medication_page.dart';

class ReviewMedicationPage extends StatelessWidget {
  const ReviewMedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicationOcrController controller =
        Get.isRegistered<MedicationOcrController>()
        ? Get.find<MedicationOcrController>()
        : Get.put(MedicationOcrController());

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
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.medicationList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'No medications detected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(
                  controller.medicationList.length,
                  (index) =>
                      _buildMedicationCard(controller.medicationList[index], index, controller),
                ),
              );
            }),
            const SizedBox(height: 8),
            // Add Missing Medication Button
            OutlinedButton(
              onPressed: () {
                Get.to(
                  () => AddMedicationPage(
                    patientId: controller.patientId.value,
                    medicationOcrController: controller,
                  ),
                );
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
          child: Obx(() {
            final isSubmitting = controller.isSubmitting.value;
            final hasMedications = controller.medicationList.isNotEmpty;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting || !hasMedications
                        ? null
                        : () async {
                            final medicationIds = await controller
                                .submitReviewedMedications();
                            final patientId = controller.patientId.value.trim();

                            if (patientId.isEmpty) {
                              Get.snackbar(
                                'Failed to analyze medications',
                                'Invalid patient ID',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (medicationIds.isNotEmpty) {
                              Get.snackbar(
                                'Success',
                                'Medications saved successfully',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.off(
                                () => const FormularyComparisonPage(),
                                arguments: {
                                  'patientId': patientId,
                                  'medicationIds': medicationIds,
                                },
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4A6E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(
                        0xFF0C4A6E,
                      ).withOpacity(0.4),
                    ),
                    child: Text(
                      isSubmitting
                          ? 'Saving medications...'
                          : 'Save Medication',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
    final controller = Get.isRegistered<MedicationOcrController>()
        ? Get.find<MedicationOcrController>()
        : Get.put(MedicationOcrController());

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
              Text(
                '${controller.medicationList.length} medications extracted',
                style: const TextStyle(
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
              Text(
                '${controller.medicationList.where((item) => item.needsReview).length} need review',
                style: const TextStyle(
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

  Widget _buildMedicationCard(MedicationModel item, int index, MedicationOcrController controller) {
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
                      item.displayName,
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
                  item.strengthAndForm,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 6),
                InlineEditableField(
                  label: 'Dose',
                  value: item.dose,
                  onChanged: (val) => controller.updateMedicationField(index, 'dose', val),
                ),
                InlineEditableField(
                  label: 'Route',
                  value: item.route,
                  onChanged: (val) => controller.updateMedicationField(index, 'route', val),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Frequency: ${item.frequency.isEmpty ? 'Not provided' : item.frequency}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                InlineEditableField(
                  label: 'Duration',
                  value: item.duration,
                  onChanged: (val) => controller.updateMedicationField(index, 'duration', val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InlineEditableField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const InlineEditableField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<InlineEditableField> createState() => _InlineEditableFieldState();
}

class _InlineEditableFieldState extends State<InlineEditableField> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveAndExit();
      }
    });
  }

  @override
  void didUpdateWidget(InlineEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    if (_controller.text != widget.value) {
      widget.onChanged(_controller.text);
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${widget.label}: ', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF38B6FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF38B6FF)),
                    ),
                    isDense: true,
                  ),
                  onFieldSubmitted: (_) => _saveAndExit(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
        _focusNode.requestFocus();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                '${widget.label}: ${widget.value.isEmpty ? 'Not provided' : widget.value}',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.value.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
