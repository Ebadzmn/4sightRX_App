import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxBool isFaceIdEnabled = false.obs;

  void toggleFaceId(bool value) {
    isFaceIdEnabled.value = value;
  }
}
