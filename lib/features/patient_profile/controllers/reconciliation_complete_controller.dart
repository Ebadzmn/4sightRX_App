import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/medication_repository.dart';

class ReconciliationMedicationItem {
  final String comparisonId;
  final String currentMedication;
  final String recommendedMedication;
  final String rationale;
  final double estimatedSavings;
  final String action;
  final RxBool isHospiceCovered;
  final String medicationName;
  final String strength;
  final String dose;
  final String frequency;

  ReconciliationMedicationItem({
    required this.comparisonId,
    required this.currentMedication,
    required this.recommendedMedication,
    required this.rationale,
    required this.estimatedSavings,
    required this.action,
    bool isHospiceCovered = false,
    required this.medicationName,
    required this.strength,
    required this.dose,
    required this.frequency,
  }) : isHospiceCovered = isHospiceCovered.obs;

  factory ReconciliationMedicationItem.fromJson(Map<String, dynamic> json) {
    final medicationId = json['medicationId'];
    String medName = '';
    String medStrength = '';
    String medDose = '';
    String medFrequency = '';

    if (medicationId is Map<String, dynamic>) {
      medName = medicationId['medicationName']?.toString() ?? '';
      medStrength = medicationId['strength']?.toString() ?? '';
      medDose = medicationId['dose']?.toString() ?? '';
      medFrequency = medicationId['frequency']?.toString() ?? '';
    }

    return ReconciliationMedicationItem(
      comparisonId: json['_id']?.toString() ?? '',
      currentMedication: json['currentMedication']?.toString() ?? '',
      recommendedMedication: json['recommendedMedication']?.toString() ?? '',
      rationale: json['rationale']?.toString() ?? '',
      estimatedSavings: _parseDouble(json['estimatedSavings']),
      action: json['action']?.toString() ?? '',
      isHospiceCovered: json['hospiceCovered'] == true,
      medicationName: medName,
      strength: medStrength,
      dose: medDose,
      frequency: medFrequency,
    );
  }

  String get savingsText {
    if (estimatedSavings <= 0) return '';
    return '\$${estimatedSavings.toStringAsFixed(0)}';
  }

  String get actionDisplayLabel {
    switch (action.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'discontinued':
        return 'D/C';
      default:
        return action;
    }
  }

  String get hospiceLabel => isHospiceCovered.value ? 'Yes' : 'No';

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class PatientInfo {
  final String firstName;
  final String lastName;
  final String mrn;
  final String dateOfBirth;
  final int age;
  final String gender;
  final String phoneNumber;
  final String medicationAllergies;
  final String notes;

  PatientInfo({
    required this.firstName,
    required this.lastName,
    required this.mrn,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.medicationAllergies,
    required this.notes,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    // Handle DOB and format it
    String dobValue = json['dob']?.toString() ?? json['dateOfBirth']?.toString() ?? '';
    if (dobValue.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dobValue);
        dobValue = '${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}/${parsed.year}';
      } catch (_) {}
    }

    // Handle Sex/Gender
    String sexValue = json['sex']?.toString() ?? json['gender']?.toString() ?? '';

    // Handle Allergies
    String allergiesValue = json['medicationAllergies']?.toString() ?? '';
    if (allergiesValue.isEmpty && json['allergies'] is List) {
      final list = json['allergies'] as List;
      allergiesValue = list
          .map((e) => e is Map ? e['name']?.toString() ?? '' : '')
          .where((e) => e.isNotEmpty)
          .join(', ');
    }

    return PatientInfo(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mrn: json['patientIdMrn']?.toString() ?? '',
      dateOfBirth: dobValue,
      age: json['age'] is int ? json['age'] : 0,
      gender: sexValue,
      phoneNumber: json['phoneNumber']?.toString() ?? 'N/A',
      medicationAllergies: allergiesValue.isNotEmpty ? allergiesValue : 'None',
      notes: json['notes']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ReconciliationCompleteController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble totalEstimatedMonthlySavings = 0.0.obs;
  final RxString pdfUrl = ''.obs;
  final Rx<PatientInfo?> patientInfo = Rx<PatientInfo?>(null);
  final RxBool isDownloading = false.obs;
  final RxBool isSharing = false.obs;

  final RxList<ReconciliationMedicationItem> continuedMedications =
      <ReconciliationMedicationItem>[].obs;
  final RxList<ReconciliationMedicationItem> discontinuedMedications =
      <ReconciliationMedicationItem>[].obs;
  final RxList<ReconciliationMedicationItem> declinedMedications =
      <ReconciliationMedicationItem>[].obs;

  final MedicationRepository _medicationRepository = MedicationRepository();

  String patientId = '';
  String _loadedPatientKey = '';

  @override
  void onInit() {
    super.onInit();
    ensureLoaded(Get.arguments);
  }

  void ensureLoaded(dynamic arguments) {
    final parsedPatientId = _resolvePatientId(arguments);
    if (parsedPatientId.isEmpty) {
      return;
    }

    final requestKey = parsedPatientId;
    if (requestKey == _loadedPatientKey &&
        (isLoading.value ||
            continuedMedications.isNotEmpty ||
            discontinuedMedications.isNotEmpty ||
            declinedMedications.isNotEmpty ||
            errorMessage.value.isNotEmpty)) {
      return;
    }

    patientId = parsedPatientId;
    _loadedPatientKey = requestKey;
    _loadSummary();
  }

  Future<void> retrySummary() async {
    if (patientId.trim().isEmpty) {
      return;
    }

    await _loadSummary(force: true);
  }

  Future<void> _loadSummary({bool force = false}) async {
    if (isLoading.value) {
      return;
    }

    if (patientId.trim().isEmpty) {
      errorMessage.value = 'Failed to load reconciliation summary';
      _clearData();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _medicationRepository.fetchFormularyComparisonSummary(
        patientId: patientId,
      );

      _parseSummary(data);

      if (force) {
        _loadedPatientKey = patientId;
      }
    } on NetworkException catch (_) {
      errorMessage.value = 'Failed to load reconciliation summary';
      _clearData();
    } catch (_) {
      errorMessage.value = 'Failed to load reconciliation summary';
      _clearData();
    } finally {
      isLoading.value = false;
    }
  }

  void _parseSummary(Map<String, dynamic> data) {
    // Parse continued medications
    final continuedList = _extractList(data, 'continuedMedications');
    continuedMedications.assignAll(
      continuedList.map(ReconciliationMedicationItem.fromJson).toList(),
    );

    // Parse discontinued medications
    final discontinuedList = _extractList(data, 'discontinuedMedications');
    discontinuedMedications.assignAll(
      discontinuedList.map(ReconciliationMedicationItem.fromJson).toList(),
    );

    // Parse declined medications
    final declinedList = _extractList(data, 'declinedMedications');
    declinedMedications.assignAll(
      declinedList.map(ReconciliationMedicationItem.fromJson).toList(),
    );

    // Parse total savings
    final savings = data['totalEstimatedMonthlySavings'];
    if (savings is num) {
      totalEstimatedMonthlySavings.value = savings.toDouble();
    }

    // Parse PDF URL
    pdfUrl.value = data['pdfUrl']?.toString() ?? '';

    // Extract patient info from the first available medication
    _extractPatientInfo(data);
  }

  void _extractPatientInfo(Map<String, dynamic> data) {
    final allLists = [
      ...(_extractList(data, 'continuedMedications')),
      ...(_extractList(data, 'discontinuedMedications')),
      ...(_extractList(data, 'declinedMedications')),
    ];

    for (final item in allLists) {
      final patientData = item['patientId'];
      if (patientData is Map<String, dynamic>) {
        patientInfo.value = PatientInfo.fromJson(patientData);
        return;
      }
    }
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Downloads the PDF to a temp file and returns its path.
  Future<String?> _downloadPdf() async {
    if (pdfUrl.value.isEmpty) {
      Get.snackbar('Error', 'PDF URL not available',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    try {
      final dir = Directory.systemTemp;
      final fileName =
          'reconciliation_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savePath = '${dir.path}/$fileName';

      // pdfUrl = "/api/v1/formulary-comparison/download-pdf/..."
      // Dio baseUrl = "http://host:port/api/v1"
      // Strip "/api/v1" prefix so Dio resolves it correctly with its baseUrl
      String downloadPath = pdfUrl.value;
      if (downloadPath.startsWith('/api/v1')) {
        downloadPath = downloadPath.replaceFirst('/api/v1', '');
      }

      debugPrint('📥 PDF Download → path: $downloadPath');
      debugPrint('📥 PDF Download → savePath: $savePath');

      await ApiClient.instance.download(downloadPath, savePath);

      final file = File(savePath);
      if (!await file.exists()) {
        debugPrint('❌ PDF file does not exist at: $savePath');
        Get.snackbar('Error', 'Downloaded file not found',
            snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      final fileSize = await file.length();
      debugPrint('✅ PDF downloaded successfully → size: $fileSize bytes');

      if (fileSize == 0) {
        debugPrint('❌ PDF file is empty');
        Get.snackbar('Error', 'Downloaded PDF is empty',
            snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      return savePath;
    } on NetworkException catch (e) {
      debugPrint('❌ PDF download NetworkException: ${e.message}');
      Get.snackbar('Download Failed', e.message,
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (e) {
      debugPrint('❌ PDF download error: $e');
      Get.snackbar('Download Failed', '$e',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  /// Download and open PDF using open_filex.
  Future<void> downloadAndOpenPdf() async {
    if (isDownloading.value) return;
    isDownloading.value = true;

    try {
      final path = await _downloadPdf();
      if (path != null) {
        debugPrint('📂 Opening PDF: $path');
        final result = await OpenFilex.open(path);
        debugPrint('📂 OpenFilex result: ${result.type} — ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Open PDF error: $e');
      Get.snackbar('Error', 'Could not open PDF',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDownloading.value = false;
    }
  }

  /// Download and share PDF using share_plus.
  Future<void> sharePdf() async {
    if (isSharing.value) return;
    isSharing.value = true;

    try {
      final path = await _downloadPdf();
      if (path != null) {
        debugPrint('📤 Sharing PDF: $path');
        final patientName = patientInfo.value?.fullName ?? 'Patient';
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            subject: 'Reconciliation Report — $patientName',
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Share PDF error: $e');
      Get.snackbar('Error', 'Could not share PDF',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSharing.value = false;
    }
  }

  void _clearData() {
    continuedMedications.clear();
    discontinuedMedications.clear();
    declinedMedications.clear();
    totalEstimatedMonthlySavings.value = 0.0;
    pdfUrl.value = '';
    patientInfo.value = null;
  }

  String _resolvePatientId(dynamic arguments) {
    if (arguments is Map) {
      return arguments['patientId']?.toString().trim() ?? '';
    }

    if (arguments is String) {
      return arguments.trim();
    }

    return '';
  }

  int get totalMedications =>
      continuedMedications.length +
      discontinuedMedications.length +
      declinedMedications.length;

  String get savingsText {
    if (totalEstimatedMonthlySavings.value <= 0) return '\$0';
    return '\$${totalEstimatedMonthlySavings.value.toStringAsFixed(0)}';
  }
}
