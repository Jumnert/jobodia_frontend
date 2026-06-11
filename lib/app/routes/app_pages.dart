import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/about/view/screens/about_us_screen.dart';
import 'package:jobodia_frontend/features/about/view/screens/privacy_policy_screen.dart';
import 'package:jobodia_frontend/features/auth/view/login_screen.dart';
import 'package:jobodia_frontend/features/auth/view/otp_verification_screen.dart';
import 'package:jobodia_frontend/features/auth/view/reset_password_screen.dart';
import 'package:jobodia_frontend/features/home/view/home_screen.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';
import 'package:jobodia_frontend/features/report/view/screens/report_screen.dart';

/// Maps route names to pages for GetX navigation.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(name: AppRoutes.aboutUs, page: () => const AboutUsScreen()),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
    ),
    GetPage(name: AppRoutes.report, page: () => const ReportScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.jobDetail,
      page: () => const JobDetailScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<JobDetailController>(JobDetailController.new),
      ),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<ProfileController>(ProfileController.new),
      ),
    ),
  ];
}
