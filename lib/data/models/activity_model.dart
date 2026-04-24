class ActivityModel {
  final String id;
  final String name;
  final String action;
  final String timeAgo;

  ActivityModel({
    required this.id,
    required this.name,
    required this.action,
    required this.timeAgo,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      timeAgo: json['timeAgo']?.toString() ?? '',
    );
  }
}
