class AllergyModel {
  final String allergyId;
  final String name;
  final bool custom;

  AllergyModel({
    required this.allergyId,
    required this.name,
    this.custom = false,
  });

  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      allergyId: json['_id']?.toString() ?? json['allergyId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      custom: json['custom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'custom': custom,
    };
    
    // Only add allergyId if it's not custom and not 'other'
    // This ensures we never send allergyId: ""
    if (!custom && allergyId.isNotEmpty && allergyId != 'other') {
      data['allergyId'] = allergyId;
    }
    
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllergyModel &&
          runtimeType == other.runtimeType &&
          allergyId == other.allergyId &&
          name == other.name;

  @override
  int get hashCode => allergyId.hashCode ^ name.hashCode;
}
