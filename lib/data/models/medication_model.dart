class MedicationModel {
  final String id;
  final String medicationName;
  final String strength;
  final String form;
  final String dose;
  final String route;
  final String frequency;
  final String duration;
  final String source;
  final String additionalInstructions;

  const MedicationModel({
    required this.id,
    required this.medicationName,
    required this.strength,
    required this.form,
    required this.dose,
    required this.route,
    required this.frequency,
    required this.duration,
    this.source = 'ocr',
    this.additionalInstructions = '',
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      medicationName:
          json['medicationName']?.toString() ??
          json['name']?.toString() ??
          json['drugName']?.toString() ??
          '',
      strength:
          json['strength']?.toString() ??
          json['dosageStrength']?.toString() ??
          '',
      form: json['form']?.toString() ?? json['dosageForm']?.toString() ?? '',
      dose: json['dose']?.toString() ?? json['dosage']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      source: json['source']?.toString() ?? 'ocr',
      additionalInstructions:
          json['additionalInstructions']?.toString() ??
          json['instructions']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'medicationName': medicationName,
      'strength': strength,
      'form': form,
      'dose': dose,
      'route': route,
      'frequency': frequency,
      'duration': duration,
      'source': source,
      'additionalInstructions': additionalInstructions,
    };
  }

  Map<String, dynamic> toBulkJson() {
    final payload = <String, dynamic>{
      'medicationName': medicationName.trim(),
      'strength': strength.trim(),
      'form': form.trim(),
      'dose': dose.trim(),
      'route': route.trim(),
      'frequency': frequency.trim(),
      'source': source.trim().toLowerCase() == 'manual' ? 'manual' : 'ocr',
    };

    final trimmedInstructions = additionalInstructions.trim();
    if (trimmedInstructions.isNotEmpty) {
      payload['additionalInstructions'] = trimmedInstructions;
    }

    return payload;
  }

  String get displayName {
    return medicationName.trim().isEmpty
        ? 'Unknown medication'
        : medicationName;
  }

  String get strengthAndForm {
    final parts = <String>[];
    if (strength.trim().isNotEmpty) {
      parts.add(strength.trim());
    }
    if (form.trim().isNotEmpty) {
      parts.add(form.trim());
    }

    if (parts.isEmpty) {
      return 'Not provided';
    }

    return parts.join(' • ');
  }

  bool get needsReview {
    return medicationName.trim().isEmpty ||
        strength.trim().isEmpty ||
        form.trim().isEmpty ||
        dose.trim().isEmpty ||
        route.trim().isEmpty ||
        frequency.trim().isEmpty ||
        duration.trim().isEmpty;
  }
}
