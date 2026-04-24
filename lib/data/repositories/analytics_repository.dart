import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../models/activity_model.dart';

class AnalyticsRepository {
  AnalyticsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<ActivityModel>> fetchRecentActivities() async {
    final response = await _apiClient.get(ApiEndpoints.recentActivities);

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

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ActivityModel.fromJson)
          .toList();
    }

    return [];
  }
}
