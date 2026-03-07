import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_medication_controller.dart';

class AddMedicationPage extends StatelessWidget {
  const AddMedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMedicationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Add Medication',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Medication Name', isRequired: true),
            const SizedBox(height: 8),
            _buildTextField(
              hint: 'Start typing medication name...',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Strength', isRequired: true),
                      const SizedBox(height: 8),
                      _buildTextField(hint: 'e.g., 10mg'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Form', isRequired: true),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        hint: 'Select form',
                        valueRx: controller.selectedForm,
                        items: controller.forms,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Dose', isRequired: true),
            const SizedBox(height: 8),
            _buildTextField(hint: 'e.g., 1 tablet, 5ml'),
            const SizedBox(height: 16),
            _buildLabel('Route', isRequired: true),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Select route',
              valueRx: controller.selectedRoute,
              items: controller.routes,
            ),
            const SizedBox(height: 16),
            _buildLabel('Frequency', isRequired: true),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: 'Select frequency',
              valueRx: controller.selectedFrequency,
              items: controller.frequencies,
            ),
            const SizedBox(height: 16),
            _buildLabel('Duration'),
            const SizedBox(height: 8),
            _buildTextField(hint: 'e.g., 7 days, ongoing'),
            const SizedBox(height: 16),
            _buildLabel('Additional Instructions'),
            const SizedBox(height: 8),
            _buildTextField(hint: 'Any special instructions...', maxLines: 4),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6A55),
                    side: const BorderSide(color: Color(0xFFFF6A55)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Save action
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4A6E), // Dark navy blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Medication',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF475569), // Slate 600
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFEF4444), // Red 500
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8), // Slate 400
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 22)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F62FE)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required RxnString valueRx,
    required List<String> items,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return DropdownButtonFormField<String>(
            value: valueRx.value,
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF94A3B8),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0F62FE)),
              ),
            ),
            hint: Text(
              hint,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valueRx.value ?? '',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList();
            },
            items: items.map((String item) {
              final bool isSelected = valueRx.value == item;
              return DropdownMenuItem<String>(
                value: item,
                child: Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Container(
                    width: constraints.maxWidth + 32,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0C4A6E)
                          : Colors.white,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              valueRx.value = newValue;
            },
          );
        });
      },
    );
  }
}
