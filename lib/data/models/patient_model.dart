import 'allergy_model.dart';

class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String mrn;
  final String patientIdMrn; // Keep for compatibility
  final String dateOfBirth;
  final int age;
  final String sex;
  final String gender; // Keep for compatibility
  final String phoneNumber;
  final List<AllergyModel> allergies;
  final String medicationAllergies; // Keep for compatibility
  final String admissionDate;
  final String status;
  final String notes;
  final String organizationId;
  final String organizationName;
  final String lifeExpectancy;
  final String createdAt;
  final String updatedAt;

  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mrn,
    required this.patientIdMrn,
    required this.dateOfBirth,
    required this.age,
    required this.sex,
    required this.gender,
    required this.phoneNumber,
    required this.allergies,
    required this.medicationAllergies,
    required this.admissionDate,
    required this.status,
    required this.notes,
    this.organizationId = '',
    this.organizationName = '',
    this.lifeExpectancy = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final mrnValue = json['mrn']?.toString() ??
        json['patientIdMrn']?.toString() ??
        json['patientIdMRN']?.toString() ??
        '';

    final sexValue = json['sex']?.toString() ?? json['gender']?.toString() ?? '';

    final allergiesRaw = json['allergies'];
    List<AllergyModel> allergiesList = [];
    if (allergiesRaw is List) {
      allergiesList = allergiesRaw
          .whereType<Map<String, dynamic>>()
          .map(AllergyModel.fromJson)
          .toList();
    }

    final medicationAllergiesValue = json['medicationAllergies']?.toString() ??
        (allergiesList.isNotEmpty ? allergiesList.map((e) => e.name).join(', ') : '');

    String orgName = json['organizationName']?.toString() ?? '';
    if (orgName.isEmpty && json['organization'] is Map) {
      orgName = json['organization']['name']?.toString() ?? '';
    }

    return PatientModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mrn: mrnValue,
      patientIdMrn: mrnValue,
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      sex: sexValue,
      gender: sexValue,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      allergies: allergiesList,
      medicationAllergies: medicationAllergiesValue,
      admissionDate: json['admissionDate']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? '',
      organizationName: orgName,
      lifeExpectancy: json['lifeExpectancy']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'mrn': mrn,
      'patientIdMrn': patientIdMrn,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'sex': sex,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'allergies': allergies.map((e) => e.toJson()).toList(),
      'medicationAllergies': medicationAllergies,
      'admissionDate': admissionDate,
      'status': status,
      'notes': notes,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'lifeExpectancy': lifeExpectancy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get formattedAdmissionDate {
    if (admissionDate.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(admissionDate);
      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');
      return '$month/$day/${parsed.year}';
    } catch (_) {
      return admissionDate;
    }
  }
}
