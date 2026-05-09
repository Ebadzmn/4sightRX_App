import 'package:get/get.dart';

import '../../core/network/network_exception.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/patient_repository.dart';
import '../patient_profile/pages/take_photo_page.dart';
import '../patient_profile/pages/upload_medication_list_page.dart';
import '../patient_profile/controllers/medication_ocr_controller.dart';

class PatientDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<PatientModel> patient = Rxn<PatientModel>();

  final RxInt medicationsCount = 8.obs;
  final RxString roomNumber = '302A'.obs;

  final List<Map<String, dynamic>> recentReconciliations = [
    {'date': 'Feb 3, 2026', 'medications': 8, 'status': 'Completed'},
    {'date': 'Jan 30, 2026', 'medications': 7, 'status': 'Completed'},
  ];

  String patientId = '';

  final PatientRepository _patientRepository = PatientRepository();

  @override
  void onInit() {
    super.onInit();
    patientId = _extractPatientId(Get.arguments);
    getPatientById();
  }

  Future<void> getPatientById() async {
    if (isLoading.value) {
      return;
    }

    final trimmedPatientId = patientId.trim();
    if (trimmedPatientId.isEmpty) {
      errorMessage.value = 'Failed to load patient data';
      patient.value = null;
      _showError('Invalid patient ID');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _patientRepository.getPatientById(trimmedPatientId);
      patient.value = result;
    } on NetworkException catch (error) {
      if (error.statusCode == 401) {
        return;
      }

      final mappedMessage = _mapErrorMessage(error);
      errorMessage.value = 'Failed to load patient data';
      patient.value = null;
      _showError(mappedMessage);
    } catch (_) {
      errorMessage.value = 'Failed to load patient data';
      patient.value = null;
      _showError('Something went wrong. Try again');
    } finally {
      isLoading.value = false;
    }
  }

  String get patientName {
    final currentPatient = patient.value;
    if (currentPatient == null) {
      return '';
    }

    return '${currentPatient.firstName} ${currentPatient.lastName}'.trim();
  }

  String get patientMrn {
    return patient.value?.patientIdMrn ?? '';
  }

  String get patientAge {
    return patient.value?.age.toString() ?? '';
  }

  String get admissionDate {
    return _formatDate(patient.value?.admissionDate ?? '');
  }

  String get dateOfBirth {
    return _formatDate(patient.value?.dateOfBirth ?? '');
  }

  String get gender {
    final value = patient.value?.gender.trim() ?? '';
    return value.isEmpty ? 'Not provided' : value;
  }

  String get phoneNumber {
    final value = patient.value?.phoneNumber.trim() ?? '';
    return value.isEmpty ? 'Not provided' : value;
  }

  String get medicationAllergies {
    final value = patient.value?.medicationAllergies.trim() ?? '';
    return value.isEmpty ? 'Not provided' : value;
  }

  String get notes {
    final value = patient.value?.notes.trim() ?? '';
    return value.isEmpty ? 'Not provided' : value;
  }

  String get createdAt {
    return _formatDateTime(patient.value?.createdAt ?? '');
  }

  String get updatedAt {
    return _formatDateTime(patient.value?.updatedAt ?? '');
  }

  void uploadFile() async {
    final ocrController = Get.put(MedicationOcrController());
    ocrController.configureForPatient(patientId);
    final success = await ocrController.pickImageFromGallery();
    if (success) {
      Get.to(
        () => const TakePhotoPage(),
        arguments: {'patientId': patientId},
      );
    }
  }

  void takePhoto() async {
    final ocrController = Get.put(MedicationOcrController());
    ocrController.configureForPatient(patientId);
    final success = await ocrController.captureImageFromCamera();
    if (success) {
      Get.to(
        () => const TakePhotoPage(),
        arguments: {'patientId': patientId},
      );
    }
  }

  String _extractPatientId(dynamic arguments) {
    if (arguments is Map) {
      return arguments['patientId']?.toString().trim() ?? '';
    }

    return '';
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (error.statusCode == 400 || message.contains('invalid')) {
      return 'Invalid patient ID';
    }

    if (error.statusCode == 404 || message.contains('not found')) {
      return 'Patient not found';
    }

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  void _showError(String message) {
    Get.snackbar(
      'Patient detail',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.isEmpty ? 'Not provided' : value;
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.isEmpty ? 'Not provided' : value;
    }

    final local = parsed.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final suffix = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')} ${_monthName(local.month)} ${local.year}, ${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $suffix';
  }

  String _monthName(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > months.length) {
      return 'N/A';
    }

    return months[month - 1];
  }
}
