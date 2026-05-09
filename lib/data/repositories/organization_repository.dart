import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../models/organization_model.dart';

class OrganizationRepository {
  OrganizationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<OrganizationModel>> getOrganizations() async {
    final response = await _apiClient.get(ApiEndpoints.organizations);

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw NetworkException(message: 'Something went wrong. Try again');
    }

    final organizationsResponse = OrganizationsResponse.fromJson(responseData);

    if (!organizationsResponse.success) {
      throw NetworkException(
        message: organizationsResponse.message.isNotEmpty
            ? organizationsResponse.message
            : 'Something went wrong. Try again',
        statusCode: response.statusCode,
      );
    }

    return organizationsResponse.data;
  }
}
