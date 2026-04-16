import 'dart:io';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  MedicationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<String>> submitReviewedMedications(
    List<MedicationModel> medications,
  ) async {
    if (medications.isEmpty) {
      throw NetworkException(message: 'No medications to save');
    }

    final response = await _apiClient.post(
      ApiEndpoints.medicationsBulk,
      body: {
        'medications': medications.map((item) => item.toBulkJson()).toList(),
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Failed to save medications');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message']?.toString() ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapBulkErrorMessage(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    final medicationIds = _extractMedicationIds(data);
    if (medicationIds.isEmpty) {
      throw NetworkException(message: 'No medication IDs returned');
    }

    return medicationIds;
  }

  Future<List<Map<String, dynamic>>> analyzeFormularyComparison({
    required String patientId,
    required List<String> medicationIds,
  }) async {
    final trimmedPatientId = patientId.trim();
    final trimmedMedicationIds = medicationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (trimmedPatientId.isEmpty) {
      throw NetworkException(message: 'Invalid patient ID');
    }

    if (trimmedMedicationIds.isEmpty) {
      throw NetworkException(message: 'No medications to analyze');
    }

    final response = await _apiClient.post(
      ApiEndpoints.formularyComparisonAnalyze,
      body: {
        'patientId': trimmedPatientId,
        'medicationIds': trimmedMedicationIds,
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Failed to analyze medications');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message']?.toString() ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapAnalyzeErrorMessage(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    final comparisons = _extractList(data);
    if (comparisons.isEmpty) {
      throw NetworkException(message: 'Failed to analyze medications');
    }

    return comparisons;
  }

  Future<MedicationModel> addMedication({
    required String medicationName,
    required String strength,
    required String form,
    required String dose,
    required String route,
    required String frequency,
    required String duration,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.medications,
      body: {
        'medicationName': medicationName,
        'strength': strength,
        'form': form,
        'dose': dose,
        'route': route,
        'frequency': frequency,
        'duration': duration,
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Failed to add medication');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message']?.toString() ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapAddErrorMessage(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    if (data is Map<String, dynamic>) {
      return MedicationModel.fromJson(data);
    }

    throw NetworkException(message: 'Failed to add medication');
  }

  Future<List<MedicationModel>> extractMedications(File file) async {
    final response = await _apiClient.postMultipart(
      ApiEndpoints.extractMedicationText,
      files: {'image': file},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Failed to extract medications');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message']?.toString() ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapErrorMessage(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    final medications = _parseMedications(data);
    if (medications.isEmpty) {
      throw NetworkException(message: 'No medications detected');
    }

    return medications;
  }

  List<MedicationModel> _parseMedications(dynamic data) {
    final list = _extractList(data);
    return list.map(MedicationModel.fromJson).toList();
  }

  List<String> _extractMedicationIds(dynamic data) {
    final list = _extractList(data);
    return list
        .map((item) => item['_id']?.toString() ?? item['id']?.toString() ?? '')
        .where((id) => id.trim().isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['medications'],
        data['items'],
        data['results'],
        data['list'],
        data['extractedMedications'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  String _mapErrorMessage({required String message, required int? statusCode}) {
    final normalizedMessage = message.toLowerCase();

    if (statusCode == 400 || normalizedMessage.contains('invalid')) {
      return 'Failed to extract medications';
    }

    if (statusCode == 404 ||
        normalizedMessage.contains('no data') ||
        normalizedMessage.contains('not found') ||
        normalizedMessage.contains('empty')) {
      return 'No medications detected';
    }

    if (statusCode == 500 || normalizedMessage.contains('server error')) {
      return 'Failed to extract medications';
    }

    if (normalizedMessage.contains('internet') ||
        normalizedMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Failed to extract medications';
  }

  String _mapAddErrorMessage({
    required String message,
    required int? statusCode,
  }) {
    final normalizedMessage = message.toLowerCase();

    if (statusCode == 400 || normalizedMessage.contains('invalid')) {
      return 'Failed to add medication';
    }

    if (statusCode == 409 || normalizedMessage.contains('duplicate')) {
      return 'Medication already exists';
    }

    if (statusCode == 500 || normalizedMessage.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (normalizedMessage.contains('internet') ||
        normalizedMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Failed to add medication';
  }

  String _mapBulkErrorMessage({
    required String message,
    required int? statusCode,
  }) {
    final normalizedMessage = message.toLowerCase();

    if (statusCode == 400 || normalizedMessage.contains('invalid')) {
      return 'Failed to save medications';
    }

    if (statusCode == 404 || normalizedMessage.contains('not found')) {
      return 'Failed to save medications';
    }

    if (statusCode == 500 || normalizedMessage.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (normalizedMessage.contains('internet') ||
        normalizedMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Failed to save medications';
  }

  String _mapAnalyzeErrorMessage({
    required String message,
    required int? statusCode,
  }) {
    final normalizedMessage = message.toLowerCase();

    if (statusCode == 400 || normalizedMessage.contains('invalid')) {
      return 'Failed to analyze medications';
    }

    if (statusCode == 404 || normalizedMessage.contains('not found')) {
      return 'Failed to analyze medications';
    }

    if (statusCode == 500 || normalizedMessage.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (normalizedMessage.contains('internet') ||
        normalizedMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Failed to analyze medications';
  }
}
