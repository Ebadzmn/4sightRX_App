import 'package:get/get.dart';

class AddMedicationController extends GetxController {
  final selectedForm = RxnString();
  final selectedRoute = RxnString();
  final selectedFrequency = RxnString();

  final forms = [
    'Tablet',
    'Capsule',
    'Liquid',
    'Injection',
    'Cream',
    'Patch',
    'Inhaler',
  ];

  final routes = [
    'Oral (PO)',
    'Sublingual (SL)',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous (SC)',
    'Topical',
    'Inhaled',
    'Rectal (PR)',
  ];

  final frequencies = [
    'Once daily (QD)',
    'Twice daily (BID)',
    'Three times daily (TID)',
    '4 Times daily (QID)',
    'Every 4 hours (Q4H)',
    'Every 6 hours (Q6H)',
    'Every 8 hours (Q8H)',
    'Every 12 hours (Q12H)',
    'As needed (PRN)',
    'Once weekly',
  ];
}
