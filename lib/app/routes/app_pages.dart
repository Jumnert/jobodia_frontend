import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/auth/view/login_screen.dart';
import 'package:jobodia_frontend/features/auth/view/otp_verification_screen.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';

/// Connects each route name to the screen GetX should display.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
  ];
}
