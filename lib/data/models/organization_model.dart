class OrganizationModel {
  final String id;
  final String name;

  const OrganizationModel({required this.id, required this.name});

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class OrganizationsResponse {
  final bool success;
  final String message;
  final List<OrganizationModel> data;

  const OrganizationsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrganizationsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final organizations = <OrganizationModel>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          final organization = OrganizationModel.fromJson(item);
          if (organization.id.isNotEmpty && organization.name.isNotEmpty) {
            organizations.add(organization);
          }
        }
      }
    }

    return OrganizationsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: organizations,
    );
  }
}
