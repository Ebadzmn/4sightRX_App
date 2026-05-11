import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../models/home_stats_model.dart';

class AnalyticsRepository {
  AnalyticsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<HomeStatsModel> fetchStats() async {
    final response = await _apiClient.get(ApiEndpoints.monthlySavings);

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final success = responseData['success'] as bool? ?? false;
    final message = responseData['message'] as String? ?? '';
    final data = responseData['data'];

    if (!success) {
      throw NetworkException(
        message: message.isNotEmpty ? message : 'Something went wrong. Try again',
        statusCode: response.statusCode,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    return HomeStatsModel.fromJson(data);
  }
}
