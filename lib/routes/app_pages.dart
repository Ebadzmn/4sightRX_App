import 'package:get/get.dart';
import '../features/auth/login/login_page.dart';
import '../features/auth/otp/otp_page.dart';
import '../features/auth/signup/signup_page.dart';
import '../features/auth/forgot_password/change_password_page.dart';
import '../features/auth/forgot_password/forgot_password_page.dart';
import '../features/home/home_binding.dart';
import '../features/main/main_page.dart';
import '../features/splash/splash_page.dart';
import '../features/recent_activity/recent_activity_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
    ),
    GetPage(name: AppRoutes.otp, page: () => const OtpPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignupPage()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordPage()),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainPage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.recentActivity,
      page: () => const RecentActivityPage(),
    ),
  ];
}
