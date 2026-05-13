import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/network_exception.dart';
import '../../routes/app_routes.dart';
import '../../data/repositories/patient_repository.dart';

import 'dart:async';
import '../../data/models/allergy_model.dart';
import '../../data/models/organization_model.dart';
import '../../data/repositories/organization_repository.dart';

class AddPatientController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patientIdMrnController = TextEditingController();
  final TextEditingController allergySearchController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString selectedSex = ''.obs;
  
  // DOB Dropdowns
  final RxString selectedMonth = ''.obs;
  final RxString selectedDay = ''.obs;
  final RxString selectedYear = ''.obs;
  
  final Rx<DateTime?> selectedAdmissionDate = Rx<DateTime?>(null);
  
  // New Fields
  final RxString selectedOrganizationId = ''.obs;
  final RxString selectedLifeExpectancy = ''.obs;
  
  // Allergies
  final RxList<AllergyModel> selectedAllergies = <AllergyModel>[].obs;
  final RxList<AllergyModel> allergySuggestions = <AllergyModel>[].obs;
  final RxBool isAllergiesLoading = false.obs;
  Timer? _debounce;

  // Organizations
  final RxList<OrganizationModel> organizationsList = <OrganizationModel>[].obs;
  final RxBool isOrganizationsLoading = false.obs;

  // Field-level Errors
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final PatientRepository _patientRepository = PatientRepository();
  final OrganizationRepository _organizationRepository = OrganizationRepository();

  final List<String> sexes = ['Male', 'Female'];
  final List<String> lifeExpectancyOptions = [
    '0-6 days',
    '1-4 weeks',
    '1-3 months',
    '4-6 months',
    '6+ months'
  ];

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  List<String> get availableDays {
    int monthIndex = months.indexOf(selectedMonth.value) + 1;
    int year = int.tryParse(selectedYear.value) ?? 2000; // Default to leap year to allow 29 days
    
    int daysInMonth = 31;
    if (selectedMonth.isNotEmpty) {
      daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    }
    
    return List.generate(daysInMonth, (index) => (index + 1).toString());
  }

  List<String> get availableYears {
    int currentYear = DateTime.now().year;
    return List.generate(120, (index) => (currentYear - index).toString());
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();

    // Reset day if it's no longer valid for the selected month/year
    everAll([selectedMonth, selectedYear], (_) {
      if (selectedDay.isNotEmpty) {
        final days = availableDays;
        if (!days.contains(selectedDay.value)) {
          selectedDay.value = '';
        }
      }
      if (selectedMonth.isNotEmpty && selectedDay.isNotEmpty && selectedYear.isNotEmpty) {
        fieldErrors.remove('dob');
      }
    });

    ever(selectedDay, (_) {
      if (selectedMonth.isNotEmpty && selectedDay.isNotEmpty && selectedYear.isNotEmpty) {
        fieldErrors.remove('dob');
      }
    });

    ever(selectedSex, (_) => fieldErrors.remove('sex'));
    ever(selectedOrganizationId, (_) => fieldErrors.remove('organizationId'));
    ever(selectedLifeExpectancy, (_) => fieldErrors.remove('lifeExpectancy'));

    // Auto-select if only one organization is available when list updates
    ever(organizationsList, (List<OrganizationModel> list) {
      if (list.length == 1 && selectedOrganizationId.isEmpty) {
        selectedOrganizationId.value = list[0].id;
      }
    });
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    patientIdMrnController.dispose();
    allergySearchController.dispose();
    notesController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchOrganizations() async {
    isOrganizationsLoading.value = true;
    try {
      final orgs = await _organizationRepository.getOrganizations();
      organizationsList.assignAll(orgs);
      
      // Also check here immediately after fetch
      if (orgs.length == 1 && selectedOrganizationId.isEmpty) {
        selectedOrganizationId.value = orgs[0].id;
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      isOrganizationsLoading.value = false;
    }
  }

  void onAllergySearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        fetchAllergies(query);
      } else {
        allergySuggestions.clear();
      }
    });
  }

  Future<void> fetchAllergies(String query) async {
    isAllergiesLoading.value = true;
    try {
      final results = await _patientRepository.fetchAllergies(search: query);
      allergySuggestions.assignAll(results);
      
      // Add "Other" option if not empty and not already in suggestions
      if (query.isNotEmpty && !allergySuggestions.any((a) => a.name.toLowerCase() == query.toLowerCase())) {
        allergySuggestions.add(AllergyModel(allergyId: 'other', name: query, custom: true));
      }
    } catch (e) {
      // Handle error
    } finally {
      isAllergiesLoading.value = false;
    }
  }

  void addAllergy(AllergyModel allergy) {
    if (!selectedAllergies.any((a) => a.name.toLowerCase() == allergy.name.toLowerCase())) {
      selectedAllergies.add(allergy);
    }
    allergySearchController.clear();
    allergySuggestions.clear();
    fieldErrors.remove('allergies');
  }

  void removeAllergy(AllergyModel allergy) {
    selectedAllergies.remove(allergy);
  }

  Future<void> pickAdmissionDate() async {
    if (isLoading.value) return;

    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedAdmissionDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedAdmissionDate.value = pickedDate;
      fieldErrors.remove('admissionDate');
    }
  }

  Future<void> addPatient() async {
    if (isLoading.value) return;

    if (!_validate()) return;

    isLoading.value = true;
    try {
      final dobStr = _getDobString();
      
      final payload = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'sex': selectedSex.value.trim(),
        'dob': dobStr,
        'mrn': patientIdMrnController.text.trim(),
        'organizationId': selectedOrganizationId.value.trim(),
        'admissionDate': _formatDateToPayload(selectedAdmissionDate.value!),
        'lifeExpectancy': selectedLifeExpectancy.value.trim(),
        'allergies': selectedAllergies.map((e) => e.toJson()).toList(),
      };
      
      debugPrint('Adding Patient Payload: $payload');
      
      await _patientRepository.addPatient(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        sex: selectedSex.value.trim(),
        dob: dobStr,
        mrn: patientIdMrnController.text.trim(),
        organizationId: selectedOrganizationId.value.trim(),
        admissionDate: _formatDateToPayload(selectedAdmissionDate.value!),
        lifeExpectancy: selectedLifeExpectancy.value.trim(),
        allergies: selectedAllergies,
      );

      _clearFields();
      Get.snackbar('Success', 'Patient added successfully 🎉', snackPosition: SnackPosition.BOTTOM);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed(AppRoutes.home, arguments: 1);
      });
    } on NetworkException catch (error) {
      if (error.statusCode != 401) {
        Get.snackbar('Error', error.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Something went wrong', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    fieldErrors.clear();
    bool isValid = true;

    if (firstNameController.text.trim().isEmpty) {
      fieldErrors['firstName'] = 'First Name is required';
      isValid = false;
    }
    if (lastNameController.text.trim().isEmpty) {
      fieldErrors['lastName'] = 'Last Name is required';
      isValid = false;
    }
    if (selectedMonth.isEmpty || selectedDay.isEmpty || selectedYear.isEmpty) {
      fieldErrors['dob'] = 'Date of Birth is required';
      isValid = false;
    }
    if (selectedSex.isEmpty) {
      fieldErrors['sex'] = 'Sex is required';
      isValid = false;
    }
    if (selectedOrganizationId.isEmpty) {
      if (organizationsList.isEmpty && !isOrganizationsLoading.value) {
        fieldErrors['organizationId'] = 'No organizations available to select';
      } else {
        fieldErrors['organizationId'] = 'Please select an organization';
      }
      isValid = false;
    }
    if (selectedAdmissionDate.value == null) {
      fieldErrors['admissionDate'] = 'Admission Date is required';
      isValid = false;
    }
    if (selectedLifeExpectancy.isEmpty) {
      fieldErrors['lifeExpectancy'] = 'Life Expectancy is required';
      isValid = false;
    }
    if (selectedAllergies.isEmpty) {
      fieldErrors['allergies'] = 'Complete Medication Allergies Field';
      isValid = false;
    }

    return isValid;
  }

  String _getDobString() {
    int monthIndex = months.indexOf(selectedMonth.value) + 1;
    final year = selectedYear.value.padLeft(4, '0');
    final month = monthIndex.toString().padLeft(2, '0');
    final day = selectedDay.value.padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDateToPayload(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    patientIdMrnController.clear();
    allergySearchController.clear();
    notesController.clear();
    selectedSex.value = '';
    selectedMonth.value = '';
    selectedDay.value = '';
    selectedYear.value = '';
    selectedAdmissionDate.value = null;
    selectedOrganizationId.value = '';
    selectedLifeExpectancy.value = '';
    selectedAllergies.clear();
    fieldErrors.clear();
  }
}
