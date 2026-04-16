import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import '../pages/review_medication_page.dart';
import 'medication_ocr_controller.dart';

class DocumentProcessingController extends GetxController {
  final RxInt progress = 0.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxBool isProcessing = false.obs;

  late final MedicationOcrController _medicationOcrController;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    _medicationOcrController = Get.isRegistered<MedicationOcrController>()
        ? Get.find<MedicationOcrController>()
        : Get.put(MedicationOcrController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        _startProcessing();
      }
    });
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }

  Future<void> _startProcessing() async {
    if (isProcessing.value) {
      return;
    }

    isProcessing.value = true;
    progress.value = 0;
    currentStepIndex.value = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (progress.value < 95) {
        progress.value += 1;
        if (progress.value < 33) {
          currentStepIndex.value = 0;
        } else if (progress.value < 66) {
          currentStepIndex.value = 1;
        } else {
          currentStepIndex.value = 2;
        }
      } else {
        timer.cancel();
      }
    });

    final success = await _medicationOcrController.extractMedications();
    _progressTimer?.cancel();

    if (!success) {
      isProcessing.value = false;
      Get.back();
      return;
    }

    progress.value = 100;
    currentStepIndex.value = 2;
    await Future.delayed(const Duration(milliseconds: 500));
    isProcessing.value = false;
    Get.off(() => const ReviewMedicationPage());
  }
}
