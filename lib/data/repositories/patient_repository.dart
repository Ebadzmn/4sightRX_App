import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../models/patient_model.dart';

class PatientPageResult {
  final List<PatientModel> patients;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;
  final bool hasExplicitTotalPages;

  const PatientPageResult({
    required this.patients,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
    required this.hasExplicitTotalPages,
  });
}

class PatientRepository {
  PatientRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<PatientModel> getPatientById(String patientId) async {
    final trimmedPatientId = patientId.trim();
    if (trimmedPatientId.isEmpty) {
      throw NetworkException(message: 'Invalid patient ID');
    }

    final response = await _apiClient.get(
      ApiEndpoints.patientDetail(trimmedPatientId),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message']?.toString() ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: _mapPatientDetailError(
          message: message,
          statusCode: response.statusCode,
        ),
        statusCode: response.statusCode,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    return PatientModel.fromJson(data);
  }

  Future<PatientPageResult> fetchPatients({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.patients,
      query: {'page': page, 'limit': limit},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: message.isNotEmpty
            ? message
            : 'Something went wrong. Try again',
        statusCode: response.statusCode,
      );
    }

    final patients = _parsePatients(data);
    final currentPage =
        _readInt(responseData, const [
          'currentPage',
          'page',
          'meta.currentPage',
          'pagination.currentPage',
        ]) ??
        page;
    final totalPages =
        _readInt(responseData, const [
          'totalPages',
          'totalPage',
          'pages',
          'meta.totalPages',
          'pagination.totalPages',
        ]) ??
        currentPage;
    final hasExplicitTotalPages =
        _readInt(responseData, const [
          'totalPages',
          'totalPage',
          'pages',
          'meta.totalPages',
          'pagination.totalPages',
        ]) !=
        null;
    final hasMorePages = hasExplicitTotalPages
        ? totalPages > currentPage
        : patients.length >= limit;

    return PatientPageResult(
      patients: patients,
      currentPage: currentPage,
      totalPages: totalPages,
      hasMorePages: hasMorePages,
      hasExplicitTotalPages: hasExplicitTotalPages,
    );
  }

  String _mapPatientDetailError({
    required String message,
    required int? statusCode,
  }) {
    final normalizedMessage = message.toLowerCase();

    if (statusCode == 400 || normalizedMessage.contains('invalid')) {
      return 'Invalid patient ID';
    }

    if (statusCode == 404 || normalizedMessage.contains('not found')) {
      return 'Patient not found';
    }

    if (statusCode == 500 || normalizedMessage.contains('server error')) {
      return 'Server error. Please try again';
    }

    if (normalizedMessage.contains('internet') ||
        normalizedMessage.contains('connection')) {
      return 'No internet connection';
    }

    return message.isNotEmpty ? message : 'Something went wrong. Try again';
  }

  List<PatientModel> _parsePatients(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(PatientModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final nestedPatients = data['patients'] ?? data['docs'] ?? data['items'];
      if (nestedPatients is List) {
        return nestedPatients
            .whereType<Map<String, dynamic>>()
            .map(PatientModel.fromJson)
            .toList();
      }
    }

    return <PatientModel>[];
  }

  int? _readInt(Map<String, dynamic> json, List<String> paths) {
    for (final path in paths) {
      final value = _readValue(json, path);
      if (value is int) {
        return value;
      }
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  dynamic _readValue(Map<String, dynamic> json, String path) {
    final segments = path.split('.');
    dynamic current = json;

    for (final segment in segments) {
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return null;
      }
    }

    return current;
  }

  Future<PatientModel> addPatient({
    required String firstName,
    required String lastName,
    required String patientIdMrn,
    required String dateOfBirth,
    required String gender,
    required String phoneNumber,
    String medicationAllergies = '',
    required String admissionDate,
    String notes = '',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.patients,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'patientIdMrn': patientIdMrn,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'medicationAllergies': medicationAllergies,
        'admissionDate': admissionDate,
        'notes': notes,
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: message.isNotEmpty
            ? message
            : 'Something went wrong. Try again',
        statusCode: response.statusCode,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    return PatientModel.fromJson(data);
  }
}
