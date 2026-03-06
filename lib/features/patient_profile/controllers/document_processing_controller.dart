import 'package:get/get.dart';
import 'dart:async';
import '../pages/processing_complete_page.dart';

class DocumentProcessingController extends GetxController {
  final RxInt progress = 0.obs;
  final RxInt currentStepIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startProcessing();
  }

  void _startProcessing() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (progress.value < 100) {
        progress.value++;

        // Update steps based on progress
        if (progress.value < 33) {
          currentStepIndex.value = 0; // OCR scanning complete (in progress)
        } else if (progress.value < 66) {
          currentStepIndex.value = 1; // Identifying medications
        } else {
          currentStepIndex.value = 2; // Extracting dosage information
        }
      } else {
        timer.cancel();
        // Delay a bit before finishing to show 100%
        Future.delayed(const Duration(milliseconds: 1000), () {
          // Navigate to next screen or show success
          Get.off(() => const ProcessingCompletePage());
        });
      }
    });
  }
}
