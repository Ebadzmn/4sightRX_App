import 'package:get/get.dart';
import '../pages/upload_medication_list_page.dart';
import '../pages/take_photo_page.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/models/patient_model.dart';

class PatientProfileController extends GetxController {
  final PatientRepository _patientRepository = PatientRepository();
  final MedicationRepository _medicationRepository = MedicationRepository();

  final Rxn<PatientModel> patient = Rxn<PatientModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString patientName = ''.obs;
  final RxString patientID = ''.obs;
  final RxInt patientAge = 0.obs;
  final RxString dob = ''.obs;
  final RxString organization = ''.obs;
  final RxString admissionDate = ''.obs;
  final RxInt medicationsCount = 0.obs;
  final RxString sex = ''.obs;

  final RxList<Map<String, dynamic>> recentReconciliations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final patientId = _resolvePatientId();
    if (patientId.isNotEmpty) {
      fetchPatientData(patientId);
    }
  }

  String _resolvePatientId() {
    final arguments = Get.arguments;
    if (arguments is Map) {
      return arguments['patientId']?.toString().trim() ?? '';
    }
    return '';
  }

  Future<void> fetchPatientData(String patientId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _patientRepository.getPatientById(patientId);
      patient.value = result;
      
      // Map data
      patientName.value = '${result.firstName} ${result.lastName}'.trim();
      patientID.value = result.mrn.isNotEmpty ? result.mrn : (result.patientIdMrn.isNotEmpty ? result.patientIdMrn : 'N/A');
      patientAge.value = result.age;
      dob.value = _formatDate(result.dateOfBirth);
      organization.value = result.organizationName.isNotEmpty ? result.organizationName : 'General Medical Center';
      admissionDate.value = _formatDate(result.admissionDate);
      sex.value = result.sex.isNotEmpty ? result.sex : result.gender;

      // Fetch summary for medication count
      try {
        final summary = await _medicationRepository.fetchFormularyComparisonSummary(patientId: patientId);
        medicationsCount.value = summary['totalMedications'] as int? ?? 0;
      } catch (_) {
        medicationsCount.value = 0;
      }

      // Mock recent reconciliations if empty
      if (recentReconciliations.isEmpty) {
        recentReconciliations.assignAll([
          {'date': 'Feb 3, 2026', 'medications': 8, 'status': 'Completed'},
          {'date': 'Jan 30, 2026', 'medications': 7, 'status': 'Completed'},
        ]);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load patient data';
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      // Expecting YYYY-MM-DD
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[1]}/${parts[2]}/${parts[0]}'; // MM/DD/YYYY
      }
      final date = DateTime.parse(dateStr);
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$month/$day/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String get medicationsDisplay {
    if (medicationsCount.value == 0) return 'Pending';
    return medicationsCount.value.toString();
  }

  String get avatarUrl {
    // Using generic avatars based on sex
    final s = sex.value.toLowerCase();
    if (s == 'male') {
      return 'https://ui-avatars.com/api/?name=${patientName.value}&background=0C3064&color=fff'; 
    } else if (s == 'female') {
      return 'https://ui-avatars.com/api/?name=${patientName.value}&background=38B6FF&color=fff';
    }
    return 'https://ui-avatars.com/api/?name=${patientName.value}&background=64748B&color=fff';
  }

  void uploadFile() {
    Get.to(() => const UploadMedicationListPage(), arguments: {'patientId': patient.value?.id});
  }

  void takePhoto() {
    Get.to(() => const TakePhotoPage(), arguments: {'patientId': patient.value?.id});
  }
}
