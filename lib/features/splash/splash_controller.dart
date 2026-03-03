import 'package:get/get.dart';
import '../auth/login/login_page.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const LoginPage());
    });
  }
}
