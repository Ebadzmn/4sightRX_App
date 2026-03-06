import 'package:get/get.dart';

class FormularyItem {
  final String currentName;
  final String currentDosage;
  final String currentFrequency;

  final String recommendedName;
  final String recommendedDosage;
  final String recommendedFrequency;

  final String warningText;
  final String savingsText;
  RxBool isHospiceCovered;

  FormularyItem({
    required this.currentName,
    required this.currentDosage,
    required this.currentFrequency,
    required this.recommendedName,
    required this.recommendedDosage,
    required this.recommendedFrequency,
    required this.warningText,
    required this.savingsText,
    bool hospiceCovered = false,
  }) : isHospiceCovered = hospiceCovered.obs;
}

class FormularyComparisonController extends GetxController {
  final List<FormularyItem> comparisons = [
    FormularyItem(
      currentName: 'Metoprolol',
      currentDosage: '50mg',
      currentFrequency: '1 tablet daily',
      recommendedName: 'Continue Current Therapy',
      recommendedDosage: '',
      recommendedFrequency: '',
      warningText: 'On preferred formulary, well-tolerated.',
      savingsText: 'Save \$85/month',
      hospiceCovered: false,
    ),
    FormularyItem(
      currentName: 'Lisinopril',
      currentDosage: '10mg',
      currentFrequency: '1 capsule daily',
      recommendedName: 'Continue Current Therapy',
      recommendedDosage: '',
      recommendedFrequency: '',
      warningText: 'Preferred ACE inhibitor, cost-effective',
      savingsText: 'Save \$120/month',
      hospiceCovered: false,
    ),
    FormularyItem(
      currentName: 'Atorvastatin',
      currentDosage: '20mg',
      currentFrequency: '1 tablet daily',
      recommendedName: 'Simvastatin',
      recommendedDosage: '40mg',
      recommendedFrequency: '1 tablet daily',
      warningText: 'Therapeutic equivalent, preferred tier',
      savingsText: 'Save \$45/month',
      hospiceCovered: true,
    ),
    FormularyItem(
      currentName: 'Warfarin',
      currentDosage: '5mg',
      currentFrequency: '1 tablet daily',
      recommendedName: 'Consider Discontinuation',
      recommendedDosage: '',
      recommendedFrequency: '',
      warningText: 'High bleeding risk in hospice setting',
      savingsText: 'Save \$65/month',
      hospiceCovered: true, // as seen in screenshot it has checkmark
    ),
  ].obs;

  void toggleHospiceCoverage(int index) {
    comparisons[index].isHospiceCovered.value =
        !comparisons[index].isHospiceCovered.value;
  }
}
