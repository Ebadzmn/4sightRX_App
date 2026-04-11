import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxBool isFaceIdEnabled = false.obs;
  final AuthRepository _authRepository = AuthRepository();

  void toggleFaceId(bool value) {
    isFaceIdEnabled.value = value;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
