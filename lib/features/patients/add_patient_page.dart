import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_patient_controller.dart';
import '../../data/models/allergy_model.dart';

class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AddPatientController controller = Get.put(AddPatientController());
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add New Patient',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormCard(
              title: 'Patient Information',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildTextField(
                        label: 'First Name',
                        controller: controller.firstNameController,
                        hint: 'Margaret',
                        isRequired: true,
                        errorText: controller.fieldErrors['firstName'],
                      )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => _buildTextField(
                        label: 'Last Name',
                        controller: controller.lastNameController,
                        hint: 'Thompson',
                        isRequired: true,
                        errorText: controller.fieldErrors['lastName'],
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'PATIENT ID / MRN',
                  controller: controller.patientIdMrnController,
                  hint: 'MRN-45678',
                  isRequired: false,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                Obx(() => _buildDobDropdowns(controller)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildDropdownField(
                        label: 'SEX',
                        value: controller.selectedSex.value.isEmpty ? null : controller.selectedSex.value,
                        onChanged: (val) => controller.selectedSex.value = val ?? '',
                        items: controller.sexes,
                        isRequired: true,
                        hint: 'Choose One',
                        errorText: controller.fieldErrors['sex'],
                      )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => _buildDropdownField(
                        label: 'ANTICIPATED LIFE EXPECTANCY',
                        value: controller.selectedLifeExpectancy.value.isEmpty ? null : controller.selectedLifeExpectancy.value,
                        onChanged: (val) => controller.selectedLifeExpectancy.value = val ?? '',
                        items: controller.lifeExpectancyOptions,
                        isRequired: true,
                        hint: 'Select',
                        errorText: controller.fieldErrors['lifeExpectancy'],
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => _buildAllergyAutocomplete(controller)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Admission Information',
              children: [
                Obx(() => _buildDropdownField(
                  label: 'ORGANIZATION / INSTITUTION',
                  value: controller.selectedOrganizationId.value.isEmpty ? null : controller.selectedOrganizationId.value,
                  onChanged: (val) => controller.selectedOrganizationId.value = val ?? '',
                  items: controller.organizationsList.map((e) => e.name).toList(),
                  values: controller.organizationsList.map((e) => e.id).toList(),
                  isRequired: true,
                  hint: 'Select Organization',
                  isLoading: controller.isOrganizationsLoading.value,
                  errorText: controller.fieldErrors['organizationId'],
                )),
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'ADMISSION DATE',
                  hint: 'DD/MM/YYYY',
                  value: controller.selectedAdmissionDate,
                  onTap: controller.pickAdmissionDate,
                  isRequired: true,
                  errorText: controller.fieldErrors['admissionDate'],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'NOTES',
                  controller: controller.notesController,
                  hint: 'Add optional notes',
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'After adding the patient, you can start a medication reconciliation process.',
                style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              controller.addPatient().then((_) {
                                if (controller.fieldErrors.isNotEmpty) {
                                  // Find the first error and scroll to a reasonable position
                                  // For simplicity, if organizationId is the error, we don't necessarily want to scroll to 0
                                  if (controller.fieldErrors.containsKey('firstName') || 
                                      controller.fieldErrors.containsKey('lastName') ||
                                      controller.fieldErrors.containsKey('dob')) {
                                    scrollController.animateTo(
                                      0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  } else {
                                    // Scroll to middle or bottom if the errors are there
                                    scrollController.animateTo(
                                      scrollController.position.maxScrollExtent * 0.6,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF0C3064),
                        disabledBackgroundColor: const Color(
                          0xFF0C3064,
                        ).withOpacity(0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Add Patient',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDobDropdowns(AddPatientController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'DATE OF BIRTH',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildDropdownField(
                label: '',
                value: controller.selectedMonth.value.isEmpty ? null : controller.selectedMonth.value,
                onChanged: (val) => controller.selectedMonth.value = val ?? '',
                items: controller.months,
                hint: 'Month',
                horizontalPadding: 6,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildDropdownField(
                label: '',
                value: controller.selectedDay.value.isEmpty ? null : controller.selectedDay.value,
                onChanged: (val) => controller.selectedDay.value = val ?? '',
                items: controller.availableDays,
                hint: 'Date',
                horizontalPadding: 6,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildDropdownField(
                label: '',
                value: controller.selectedYear.value.isEmpty ? null : controller.selectedYear.value,
                onChanged: (val) => controller.selectedYear.value = val ?? '',
                items: controller.availableYears,
                hint: 'Year',
                horizontalPadding: 6,
              ),
            ),
          ],
        ),
        if (controller.fieldErrors['dob'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              controller.fieldErrors['dob']!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildAllergyAutocomplete(AddPatientController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'MEDICATION ALLERGIES',
          controller: controller.allergySearchController,
          hint: 'Search allergies...',
          isRequired: true,
          onChanged: controller.onAllergySearchChanged,
          errorText: controller.fieldErrors['allergies'],
        ),
        if (controller.allergySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.allergySuggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final allergy = controller.allergySuggestions[index];
                return ListTile(
                  title: Text(
                    allergy.custom ? 'Add "${allergy.name}" as custom' : allergy.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: allergy.custom ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                      fontWeight: allergy.custom ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () => controller.addAllergy(allergy),
                );
              },
            ),
          ),
        if (controller.isAllergiesLoading.value)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.selectedAllergies.map((allergy) {
            return Chip(
              label: Text(allergy.name, style: const TextStyle(fontSize: 12)),
              backgroundColor: const Color(0xFFF1F5F9),
              deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
              onDeleted: () => controller.removeAllergy(allergy),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime?> value,
    required VoidCallback onTap,
    bool isRequired = false,
    String? hint,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final DateTime? selectedValue = value.value;
          final bool isEmpty = selectedValue == null;
          final String displayText = isEmpty ? (hint ?? '') : _formatDate(selectedValue);

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: errorText != null ? Colors.red : const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: isEmpty ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    List<String>? values,
    bool isRequired = false,
    String? hint,
    bool isLoading = false,
    String? errorText,
    double horizontalPadding = 16,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Builder(builder: (context) {
          final bool isSelected = value != null && value.isNotEmpty;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? Colors.red
                    : (isSelected ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE)),
                width: isSelected ? 1.5 : 1.0,
              ),
              color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF1E293B),
                      ),
                      isExpanded: true,
                      hint: Text(
                        hint ?? 'Select',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      items: List.generate(items.length, (index) {
                        final String itemLabel = items[index];
                        final String? itemValue = values != null ? values[index] : items[index];

                        return DropdownMenuItem<String>(
                          value: itemValue,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  itemLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (values != null && label.contains('ORGANIZATION'))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ID: ${values[index]}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      onChanged: onChanged,
                    ),
                  ),
          );
        }),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }
}
