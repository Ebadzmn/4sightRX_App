import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/medication_repository.dart';

class FinalMedicationItem {
  final String medicationId;
  final String name;
  final String dosage;
  final String frequency;
  final RxBool isHospiceCovered;

  FinalMedicationItem({
    required this.medicationId,
    required this.name,
    required this.dosage,
    required this.frequency,
    bool isHospiceCovered = true,
  }) : isHospiceCovered = isHospiceCovered.obs;

  factory FinalMedicationItem.fromJson(Map<String, dynamic> json) {
    return FinalMedicationItem(
      medicationId: _extractIdentifier(json),
      name: _firstString(json, [
        'currentMedication',
        'currentName',
        'medicationName',
        'name',
        'drugName',
      ]),
      dosage: _firstString(json, [
        'dosage',
        'strength',
        'dose',
        'dosageInfo',
        'instructions',
      ]),
      frequency: _firstString(json, [
        'frequency',
        'schedule',
        'frequencyInfo',
        'routeFrequency',
      ]),
      isHospiceCovered: _parseBool(_readValue(json, 'hospiceCovered')),
    );
  }

  String get hospiceLabel => isHospiceCovered.value ? 'Yes' : 'No';
}

class ChangedMedicationItem {
  final String comparisonId;
  final String currentMedication;
  final String recommendedMedication;
  final String rationale;
  final String estimatedSavings;
  final String action;
  final RxBool isHospiceCovered;

  ChangedMedicationItem({
    required this.comparisonId,
    required this.currentMedication,
    required this.recommendedMedication,
    required this.rationale,
    required this.estimatedSavings,
    required this.action,
    bool isHospiceCovered = true,
  }) : isHospiceCovered = isHospiceCovered.obs;

  factory ChangedMedicationItem.fromJson(Map<String, dynamic> json) {
    return ChangedMedicationItem(
      comparisonId: _extractIdentifier(json),
      currentMedication: _firstString(json, [
        'currentMedication',
        'currentName',
        'currentDrug',
      ]),
      recommendedMedication: _firstString(json, [
        'recommendedMedication',
        'recommendedName',
        'suggestedDrug',
        'newMedication',
      ]),
      rationale: _firstString(json, [
        'rationale',
        'warningText',
        'explanation',
        'reason',
      ]),
      estimatedSavings: _firstString(json, [
        'estimatedSavings',
        'savingsText',
        'monthlySavings',
      ])
          .let(_formatSavings),
      action: _firstString(json, ['action', 'status']),
      isHospiceCovered: _parseBool(_readValue(json, 'hospiceCovered')),
    );
  }

  String get name {
    final preferredName = recommendedMedication.trim();
    if (preferredName.isNotEmpty) {
      return preferredName;
    }

    return currentMedication.trim().isNotEmpty ? currentMedication : 'Not provided';
  }

  String get dosageInfo {
    return rationale.trim().isNotEmpty ? rationale : 'No rationale provided';
  }

  String get oldMedName {
    return currentMedication.trim().isNotEmpty ? currentMedication : 'Not provided';
  }

  String get frequency {
    return estimatedSavings.trim().isNotEmpty
        ? 'Savings: $estimatedSavings'
        : '';
  }

  String get actionLabel => action.trim();

  String get actionDisplayLabel {
    switch (actionLabel.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'discontinued':
        return 'D/C';
      default:
        return '';
    }
  }

  String get hospiceLabel => isHospiceCovered.value ? 'Yes' : 'No';
}

class DiscontinuedMedicationItem {
  final String comparisonId;
  final String name;
  final String dosage;
  final String frequency;
  final String reason;

  DiscontinuedMedicationItem({
    required this.comparisonId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reason,
  });

  factory DiscontinuedMedicationItem.fromJson(Map<String, dynamic> json) {
    return DiscontinuedMedicationItem(
      comparisonId: _extractIdentifier(json),
      name: _firstString(json, [
        'currentMedication',
        'currentName',
        'medicationName',
        'name',
        'drugName',
      ]),
      dosage: _firstString(json, [
        'dosage',
        'strength',
        'dose',
      ]),
      frequency: _firstString(json, [
        'frequency',
        'schedule',
        'routeFrequency',
      ]),
      reason: _firstString(json, [
        'reasonNote',
        'reason',
        'rationale',
        'explanation',
      ]),
    );
  }
}

class ReconciliationCompleteController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString totalSavings = ''.obs;
  final RxList<FinalMedicationItem> continuedMedications =
      <FinalMedicationItem>[].obs;
  final RxList<ChangedMedicationItem> changedMedications =
      <ChangedMedicationItem>[].obs;
  final RxList<DiscontinuedMedicationItem> discontinuedMedications =
      <DiscontinuedMedicationItem>[].obs;

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
            changedMedications.isNotEmpty ||
            discontinuedMedications.isNotEmpty ||
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
      final parsed = _parseSummary(data);

      continuedMedications.assignAll(parsed.continuedMedications);
      changedMedications.assignAll(parsed.changedMedications);
      discontinuedMedications.assignAll(parsed.discontinuedMedications);
      totalSavings.value = parsed.totalEstimatedMonthlySavings;

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

  void toggleContinuedHospice(int index) {
    continuedMedications[index].isHospiceCovered.toggle();
  }

  void toggleChangedHospice(int index) {
    changedMedications[index].isHospiceCovered.toggle();
  }

  void _clearData() {
    continuedMedications.clear();
    changedMedications.clear();
    discontinuedMedications.clear();
    totalSavings.value = '';
  }

  _SummaryParseResult _parseSummary(Map<String, dynamic> data) {
    final continuedItems = _extractSectionList(
      data,
      const ['continuedMedications', 'continued', 'activeMedications'],
    );
    final changedItems = _extractSectionList(
      data,
      const ['changedMedications', 'changed', 'comparisons'],
    );
    final discontinuedItems = _extractSectionList(
      data,
      const ['discontinuedMedications', 'discontinued', 'stoppedMedications'],
    );

    return _SummaryParseResult(
      continuedMedications: continuedItems
          .map(FinalMedicationItem.fromJson)
          .toList(),
      changedMedications:
          changedItems.map(ChangedMedicationItem.fromJson).toList(),
      discontinuedMedications: discontinuedItems
          .map(DiscontinuedMedicationItem.fromJson)
          .toList(),
      totalEstimatedMonthlySavings: _formatSavings(
        _readValue(data, 'totalEstimatedMonthlySavings') ??
            _readValue(data, 'totalSavings') ??
            _readValue(data, 'monthlySavings'),
      ),
    );
  }

  List<Map<String, dynamic>> _extractSectionList(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final candidate = _readValue(data, key);
      final list = _normalizeList(candidate);
      if (list.isNotEmpty) {
        return _dedupeByIdentifier(list);
      }
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _normalizeList(dynamic candidate) {
    if (candidate is List) {
      return candidate.whereType<Map<String, dynamic>>().toList();
    }

    if (candidate is Map<String, dynamic>) {
      final nestedCandidates = [
        candidate['items'],
        candidate['results'],
        candidate['list'],
        candidate['data'],
      ];

      for (final nested in nestedCandidates) {
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _dedupeByIdentifier(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <String>{};
    final uniqueItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final dedupeKey = _extractIdentifier(item);
      final fallbackKey = dedupeKey.isNotEmpty
          ? dedupeKey
          : [
              _firstString(item, const ['currentMedication', 'currentName', 'name']),
              _firstString(item, const ['recommendedMedication', 'recommendedName']),
              _firstString(item, const ['action', 'status']),
            ].join('|');

      if (seen.add(fallbackKey)) {
        uniqueItems.add(item);
      }
    }

    return uniqueItems;
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
}

class _SummaryParseResult {
  final List<FinalMedicationItem> continuedMedications;
  final List<ChangedMedicationItem> changedMedications;
  final List<DiscontinuedMedicationItem> discontinuedMedications;
  final String totalEstimatedMonthlySavings;

  _SummaryParseResult({
    required this.continuedMedications,
    required this.changedMedications,
    required this.discontinuedMedications,
    required this.totalEstimatedMonthlySavings,
  });
}

String _extractIdentifier(Map<String, dynamic> json) {
  return _firstString(json, const [
    '_id',
    'comparisonId',
    'id',
    'medicationId._id',
    'medicationId.id',
    'itemId',
  ]);
}

dynamic _readValue(dynamic value, String path) {
  dynamic current = value;

  for (final segment in path.split('.')) {
    if (current is Map<String, dynamic> && current.containsKey(segment)) {
      current = current[segment];
      continue;
    }

    return null;
  }

  return current;
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _readValue(json, key);
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }

  return '';
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'covered';
}

String _formatSavings(dynamic value) {
  if (value == null) {
    return '';
  }

  if (value is num) {
    return '\$${value.toString()}';
  }

  final text = value.toString().trim();
  if (text.isEmpty) {
    return '';
  }

  if (text.startsWith(r'$')) {
    return text;
  }

  return text;
}

extension _StringFormatExtension on String {
  String let(String Function(dynamic value) formatter) {
    return formatter(this);
  }
}
