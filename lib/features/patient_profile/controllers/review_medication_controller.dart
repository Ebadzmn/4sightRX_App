import 'package:get/get.dart';

class MedicationItem {
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final bool needsReview;

  MedicationItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    this.needsReview = false,
  });
}

class ReviewMedicationController extends GetxController {
  final List<MedicationItem> medications = [
    MedicationItem(
      name: 'Metoprolol',
      dosage: '50mg • 1 tablet',
      frequency: 'Once daily',
      instructions: 'Take in the morning',
    ),
    MedicationItem(
      name: 'Lisinopril',
      dosage: '10mg • 2 tablets',
      frequency: 'Twice daily',
      instructions: 'Take with meals',
    ),
    MedicationItem(
      name: 'Atorvastatin',
      dosage: '20mg • 1 tablet',
      frequency: 'Once daily at bedtime',
      instructions: '',
    ),
    MedicationItem(
      name: 'Aspirin',
      dosage: '81mg • 1 tablet',
      frequency: 'Once daily',
      instructions: '',
    ),
    MedicationItem(
      name: 'Furosemide',
      dosage: '40mcg • 1 tablet',
      frequency: 'Once daily',
      instructions: 'Take 30 min before breakfast',
      needsReview: true,
    ),
  ].obs;

  void deleteMedication(int index) {
    medications.removeAt(index);
  }
}
