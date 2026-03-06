import 'package:get/get.dart';

class FinalMedicationItem {
  final String name;
  final String dosage;
  final String frequency;
  final RxBool isHospiceCovered;

  FinalMedicationItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    bool isHospiceCovered = true,
  }) : isHospiceCovered = isHospiceCovered.obs;
}

class ChangedMedicationItem {
  final String name;
  final String dosageInfo;
  final String oldMedName;
  final String frequency;
  final RxBool isHospiceCovered;

  ChangedMedicationItem({
    required this.name,
    required this.dosageInfo,
    required this.oldMedName,
    required this.frequency,
    bool isHospiceCovered = true,
  }) : isHospiceCovered = isHospiceCovered.obs;
}

class DiscontinuedMedicationItem {
  final String name;
  final String dosage;
  final String frequency;
  final String reason;

  DiscontinuedMedicationItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reason,
  });
}

class ReconciliationCompleteController extends GetxController {
  final List<FinalMedicationItem> continuedMedications = [
    FinalMedicationItem(
      name: 'Metoprolol',
      dosage: '10mg • 1 tablet',
      frequency: 'Once daily',
    ),
    FinalMedicationItem(
      name: 'Lisinopril',
      dosage: '10mg • 1 tablet',
      frequency: 'Once daily',
    ),
    FinalMedicationItem(
      name: 'Aspirin',
      dosage: '81mg • 1 tablet',
      frequency: 'Once daily',
    ),
  ];

  final List<ChangedMedicationItem> changedMedications = [
    ChangedMedicationItem(
      name: 'Simvastatin 40mg',
      dosageInfo: '1 tablet daily',
      oldMedName: 'Atorvastatin 20mg',
      frequency: 'Changed from Atorvastatin 20mg',
    ),
    ChangedMedicationItem(
      name: 'Pantoprazole 40mg',
      dosageInfo: 'PO Daily before breakfast',
      oldMedName: 'Omeprazole 20mg',
      frequency: 'Changed from Omeprazole 20mg',
    ),
  ];

  final List<DiscontinuedMedicationItem> discontinuedMedications = [
    DiscontinuedMedicationItem(
      name: 'Warfarin',
      dosage: '5mg • 1 capsule',
      frequency: 'PO Daily at 5pm',
      reason: 'Reason: High bleeding risk',
    ),
  ];

  void toggleContinuedHospice(int index) {
    continuedMedications[index].isHospiceCovered.toggle();
  }

  void toggleChangedHospice(int index) {
    changedMedications[index].isHospiceCovered.toggle();
  }
}
