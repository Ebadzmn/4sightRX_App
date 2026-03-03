import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_patient_controller.dart';

class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AddPatientController controller = Get.put(AddPatientController());

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Personal Information Card
            _buildFormCard(
              title: 'Personal Information',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First Name',
                        controller: controller.firstNameController,
                        hint: 'Margaret',
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last Name',
                        controller: controller.lastNameController,
                        hint: 'Thompson',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'PATIENT ID / MRN',
                  controller: controller.patientIdController,
                  hint: 'MRN-45678',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Date of Birth',
                        controller: controller.dobController,
                        hint: '12/31/1948',
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Age',
                        controller: controller.ageController,
                        hint: '78',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'GENDER',
                  value: controller.selectedGender,
                  items: controller.genders,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'PHONE NUMBER',
                  controller: controller.phoneController,
                  hint: '017444114084',
                  prefixIcon: Icons.phone_outlined,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'MEDICATION ALLERGIES',
                  controller: controller.allergiesController,
                  hint: '',
                  isRequired: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Admission Information Card
            _buildFormCard(
              title: 'Admission Information',
              children: [
                _buildDropdownField(
                  label: 'FACILITY',
                  value: controller.selectedFacility,
                  items: controller.facilities,
                  isRequired: true,
                  hint: 'Select Facility',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'ADMISSION DATE',
                  controller: controller.admissionDateController,
                  hint: '01/28/2026',
                  isRequired: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Information Box
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
            // Actions
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
                  child: ElevatedButton(
                    onPressed: controller.addPatient,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF0C3064),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add Patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
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
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required RxString value,
    required List<String> items,
    bool isRequired = false,
    String? hint,
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
        LayoutBuilder(
          builder: (context, constraints) {
            return Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.value.isEmpty ? null : value.value,
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1E293B),
                    ),
                    isExpanded: true,
                    hint: hint != null
                        ? Text(
                            hint,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : null,
                    selectedItemBuilder: (BuildContext context) {
                      return items.map<Widget>((String item) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value.value,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    items: items.map((String item) {
                      final bool isSelected = value.value == item;
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Transform.translate(
                          offset: const Offset(-16, 0),
                          child: Container(
                            width: constraints.maxWidth + 32,
                            height: 48, // Standard dropdown item height
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF38B6FF)
                                  : Colors.white,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        value.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
