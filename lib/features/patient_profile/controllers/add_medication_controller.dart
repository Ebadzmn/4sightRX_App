import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../data/models/medication_model.dart';
import 'medication_ocr_controller.dart';

class AddMedicationController extends GetxController {
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController strengthController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  final selectedForm = RxnString();
  final selectedRoute = RxnString();
  final selectedFrequency = RxnString();
  final RxBool isSaving = false.obs;

  final forms = [
    'Tablet',
    'Capsule',
    'Liquid',
    'Injection',
    'Cream',
    'Patch',
    'Inhaler',
  ];

  final routes = [
    'Oral (PO)',
    'Sublingual (SL)',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous (SC)',
    'Topical',
    'Inhaled',
    'Rectal (PR)',
  ];

  final frequencies = [
    'Once daily (QD)',
    'Twice daily (BID)',
    'Three times daily (TID)',
    '4 Times daily (QID)',
    'Every 4 hours (Q4H)',
    'Every 6 hours (Q6H)',
    'Every 8 hours (Q8H)',
    'Every 12 hours (Q12H)',
    'As needed (PRN)',
    'Once weekly',
  ];

  @override
  void onClose() {
    medicationNameController.dispose();
    strengthController.dispose();
    doseController.dispose();
    durationController.dispose();
    instructionsController.dispose();
    super.onClose();
  }

  Future<void> saveMedication() async {
    if (isSaving.value) {
      return;
    }

    isSaving.value = true;

    try {
      final medication = MedicationModel(
        id: '',
        medicationName: medicationNameController.text.trim(),
        strength: strengthController.text.trim(),
        form: selectedForm.value!.trim(),
        dose: doseController.text.trim(),
        route: selectedRoute.value!.trim(),
        frequency: selectedFrequency.value!.trim(),
        duration: durationController.text.trim(),
        source: 'manual',
        additionalInstructions: instructionsController.text.trim(),
      );

      final medicationOcrController =
          Get.isRegistered<MedicationOcrController>()
          ? Get.find<MedicationOcrController>()
          : Get.put(MedicationOcrController());

      medicationOcrController.appendMedication(medication);
      isSaving.value = false;
      Get.back();
      Get.snackbar(
        'Success',
        'Medication added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _clearFields();
    } catch (_) {
      Get.snackbar(
        'Failed to add medication',
        'Failed to add medication',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _clearFields() {
    medicationNameController.clear();
    strengthController.clear();
    doseController.clear();
    durationController.clear();
    instructionsController.clear();
    selectedForm.value = null;
    selectedRoute.value = null;
    selectedFrequency.value = null;
  }
}
