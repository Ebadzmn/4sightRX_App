import 'package:get/get.dart';
import 'reconciliation_complete_controller.dart';

class ExportMedicationListController extends GetxController {
  final RxBool isExported = false.obs;

  Future<void> exportToEMR() async {
    final reconController = Get.find<ReconciliationCompleteController>();
    await reconController.downloadAndOpenPdf();
    isExported.value = true;
  }
}
