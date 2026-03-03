import 'package:get/get.dart';

class PatientProfileController extends GetxController {
  final RxString patientName = 'Margaret Thompson'.obs;
  final RxString patientID = 'MRN-45678'.obs;
  final RxInt patientAge = 78.obs;
  final RxString roomNumber = '302A'.obs;
  final RxString admissionDate = 'Jan 28, 2026'.obs;
  final RxInt medicationsCount = 8.obs;

  final List<Map<String, dynamic>> recentReconciliations = [
    {'date': 'Feb 3, 2026', 'medications': 8, 'status': 'Completed'},
    {'date': 'Jan 30, 2026', 'medications': 7, 'status': 'Completed'},
  ];

  void startReconciliation() {
    // Navigate to reconciliation flow
  }

  void uploadFile() {
    // Handle file upload
  }

  void takePhoto() {
    // Handle camera
  }
}
