import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await _storageService.getAuthToken();
    final isLoggedIn = await _storageService.isLoggedIn();

    if (token != null && token.isNotEmpty && isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
