import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPatientController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();

  final RxString selectedGender = 'Female'.obs;
  final RxString selectedFacility = ''.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> facilities = [
    'St. Mary\'s General Hospital',
    'City Clinic',
    'Memorial Hospital',
  ];

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    patientIdController.dispose();
    dobController.dispose();
    ageController.dispose();
    phoneController.dispose();
    allergiesController.dispose();
    admissionDateController.dispose();
    super.onClose();
  }

  void addPatient() {
    // Implement add patient logic here
    Get.back();
    Get.snackbar(
      'Success',
      'Patient added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
