import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/network_exception.dart';
import '../../routes/app_routes.dart';
import '../../data/repositories/patient_repository.dart';

class AddPatientController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patientIdMrnController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController medicationAllergiesController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString selectedGender = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedAdmissionDate = Rx<DateTime?>(null);

  final PatientRepository _patientRepository = PatientRepository();

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    patientIdMrnController.dispose();
    phoneNumberController.dispose();
    medicationAllergiesController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickDateOfBirth() async {
    if (isLoading.value) {
      return;
    }

    final pickedDate = await _pickDate(
      initialDate:
          selectedDateOfBirth.value ??
          DateTime.now().subtract(const Duration(days: 365 * 30)),
    );

    if (pickedDate != null) {
      selectedDateOfBirth.value = pickedDate;
    }
  }

  Future<void> pickAdmissionDate() async {
    if (isLoading.value) {
      return;
    }

    final pickedDate = await _pickDate(
      initialDate: selectedAdmissionDate.value ?? DateTime.now(),
    );

    if (pickedDate != null) {
      selectedAdmissionDate.value = pickedDate;
    }
  }

  Future<DateTime?> _pickDate({required DateTime initialDate}) async {
    final context = Get.context;
    if (context == null) {
      return null;
    }

    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();
    final safeInitialDate = initialDate.isAfter(lastDate)
        ? lastDate
        : (initialDate.isBefore(firstDate) ? firstDate : initialDate);

    return showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  Future<void> addPatient() async {
    if (isLoading.value) {
      return;
    }

    final validationMessage = _validate();
    if (validationMessage != null) {
      Get.snackbar(
        'Add patient failed',
        validationMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _patientRepository.addPatient(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        patientIdMrn: patientIdMrnController.text.trim().toUpperCase(),
        dateOfBirth: _formatDate(selectedDateOfBirth.value!),
        gender: selectedGender.value.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        medicationAllergies: medicationAllergiesController.text.trim(),
        admissionDate: _formatDate(selectedAdmissionDate.value!),
        notes: notesController.text.trim(),
      );

      _clearFields();
      Get.snackbar(
        'Success',
        'Patient added successfully 🎉',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed(AppRoutes.home, arguments: 1);
      });
    } on NetworkException catch (error) {
      if (error.statusCode == 401) {
        return;
      }

      Get.snackbar(
        'Add patient failed',
        _mapErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Add patient failed',
        'Something went wrong. Try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? _validate() {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        patientIdMrnController.text.trim().isEmpty ||
        selectedDateOfBirth.value == null ||
        selectedGender.value.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        selectedAdmissionDate.value == null) {
      return 'Please fill all required fields';
    }

    final mrn = patientIdMrnController.text.trim().toUpperCase();
    if (!RegExp(r'^MRN-\d{5}$').hasMatch(mrn)) {
      return 'Please enter a valid MRN in the format MRN-XXXXX';
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    patientIdMrnController.clear();
    phoneNumberController.clear();
    medicationAllergiesController.clear();
    notesController.clear();
    selectedGender.value = '';
    selectedDateOfBirth.value = null;
    selectedAdmissionDate.value = null;
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('already exists') ||
        message.contains('duplicate') ||
        message.contains('mrn')) {
      return 'Patient ID already exists';
    }

    if (message.contains('invalid date format') ||
        message.contains('date format')) {
      return 'Invalid date format';
    }

    if (message.contains('required') ||
        message.contains('missing') ||
        message.contains('fill all required fields')) {
      return 'Please fill all required fields';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }
}
