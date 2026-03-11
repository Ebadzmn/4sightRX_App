import 'package:get/get.dart';

class ExportMedicationListController extends GetxController {
  final RxBool isExported = false.obs;

  void exportToEMR() {
    isExported.value = true;
  }
}
