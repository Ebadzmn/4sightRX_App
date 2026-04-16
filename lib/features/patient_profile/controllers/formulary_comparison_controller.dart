import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/medication_repository.dart';

class FormularyItem {
  final String currentMedication;
  final String recommendedMedication;
  final String rationale;
  final String estimatedSavings;
  final String action;
  final RxBool isHospiceCovered;

  FormularyItem({
    required this.currentMedication,
    required this.recommendedMedication,
    required this.rationale,
    required this.estimatedSavings,
    required this.action,
    bool hospiceCovered = false,
  }) : isHospiceCovered = hospiceCovered.obs;

  factory FormularyItem.fromJson(Map<String, dynamic> json) {
    return FormularyItem(
      currentMedication:
          json['currentMedication']?.toString() ??
          json['currentName']?.toString() ??
          json['currentDrug']?.toString() ??
          '',
      recommendedMedication:
          json['recommendedMedication']?.toString() ??
          json['recommendedName']?.toString() ??
          json['suggestedDrug']?.toString() ??
          '',
      rationale:
          json['rationale']?.toString() ??
          json['warningText']?.toString() ??
          json['explanation']?.toString() ??
          '',
      estimatedSavings:
          json['estimatedSavings']?.toString() ??
          json['savingsText']?.toString() ??
          '',
      action: json['action']?.toString() ?? '',
      hospiceCovered: _parseBool(json['hospiceCovered']),
    );
  }

  String get currentName {
    return currentMedication.trim().isEmpty ? 'Not provided' : currentMedication;
  }

  String get currentDosage => '';

  String get currentFrequency => '';

  String get recommendedName {
    return recommendedMedication.trim().isEmpty
        ? 'Not provided'
        : recommendedMedication;
  }

  String get recommendedDosage => '';

  String get recommendedFrequency => '';

  String get warningText {
    return rationale.trim().isEmpty ? 'No rationale provided' : rationale;
  }

  String get savingsText {
    return estimatedSavings.trim().isEmpty
        ? 'Savings not available'
        : estimatedSavings;
  }

  String get actionLabel {
    return action.trim();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'covered';
  }
}

class FormularyComparisonController extends GetxController {
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FormularyItem> comparisons = <FormularyItem>[].obs;

  final MedicationRepository _medicationRepository = MedicationRepository();

  String patientId = '';
  final List<String> medicationIds = <String>[];
  String _loadedArgumentsKey = '';

  @override
  void onInit() {
    super.onInit();
    ensureLoaded(Get.arguments);
  }

  void ensureLoaded(dynamic arguments) {
    final parsed = _parseArguments(arguments);
    final requestKey = _argumentsKey(parsed.patientId, parsed.medicationIds);

    if (requestKey == _loadedArgumentsKey &&
        (isAnalyzing.value ||
            comparisons.isNotEmpty ||
            errorMessage.value.isNotEmpty)) {
      return;
    }

    patientId = parsed.patientId;
    medicationIds
      ..clear()
      ..addAll(parsed.medicationIds);
    _loadedArgumentsKey = requestKey;

    _analyzeMedications();
  }

  Future<void> retryAnalysis() async {
    if (patientId.trim().isEmpty || medicationIds.isEmpty) {
      return;
    }

    await _analyzeMedications();
  }

  Future<void> _analyzeMedications() async {
    if (isAnalyzing.value) {
      return;
    }

    if (patientId.trim().isEmpty) {
      errorMessage.value = 'Failed to analyze medications';
      comparisons.clear();
      return;
    }

    if (medicationIds.isEmpty) {
      errorMessage.value = 'No medications to analyze';
      comparisons.clear();
      return;
    }

    isAnalyzing.value = true;
    errorMessage.value = '';

    try {
      final result = await _medicationRepository.analyzeFormularyComparison(
        patientId: patientId,
        medicationIds: medicationIds,
      );

      comparisons.assignAll(result.map(FormularyItem.fromJson).toList());

      if (comparisons.isEmpty) {
        throw NetworkException(message: 'Failed to analyze medications');
      }
    } on NetworkException catch (error) {
      final mappedMessage = _mapErrorMessage(error);
      errorMessage.value = mappedMessage;
      comparisons.clear();
    } catch (_) {
      errorMessage.value = 'Failed to analyze medications';
      comparisons.clear();
    } finally {
      isAnalyzing.value = false;
    }
  }

  void toggleHospiceCoverage(int index) {
    comparisons[index].isHospiceCovered.value =
        !comparisons[index].isHospiceCovered.value;
  }

  ({String patientId, List<String> medicationIds}) _parseArguments(
    dynamic arguments,
  ) {
    if (arguments is Map) {
      final extractedPatientId = arguments['patientId']?.toString().trim() ?? '';
      final extractedMedicationIds = _extractMedicationIds(
        arguments['medicationIds'],
      );
      return (
        patientId: extractedPatientId,
        medicationIds: extractedMedicationIds,
      );
    }

    return (patientId: '', medicationIds: <String>[]);
  }

  List<String> _extractMedicationIds(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  String _argumentsKey(String patientId, List<String> medicationIds) {
    return '$patientId|${medicationIds.join(',')}';
  }

  String _mapErrorMessage(NetworkException error) {
    final message = error.message.toLowerCase();

    if (message.contains('internet') || message.contains('connection')) {
      return 'No internet connection';
    }

    if (error.statusCode == 500 || message.contains('server error')) {
      return 'Server error. Please try again';
    }

    return 'Failed to analyze medications';
  }
}
