import 'package:get/get.dart';
import '../pages/review_medication_page.dart';
import 'dart:async';

class ProcessingCompleteController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToReview();
  }

  void _navigateToReview() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(() => const ReviewMedicationPage());
    });
  }
}
