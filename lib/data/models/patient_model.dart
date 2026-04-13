class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String patientIdMrn;
  final String dateOfBirth;
  final int age;
  final String gender;
  final String phoneNumber;
  final String medicationAllergies;
  final String admissionDate;
  final String status;
  final String notes;
  final String createdAt;
  final String updatedAt;

  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patientIdMrn,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.medicationAllergies,
    required this.admissionDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      patientIdMrn:
          json['patientIdMrn']?.toString() ??
          json['patientIdMRN']?.toString() ??
          '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      gender: json['gender']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      medicationAllergies: json['medicationAllergies']?.toString() ?? '',
      admissionDate: json['admissionDate']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'patientIdMrn': patientIdMrn,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'medicationAllergies': medicationAllergies,
      'admissionDate': admissionDate,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
