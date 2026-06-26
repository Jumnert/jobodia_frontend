import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/middleware/auth_middleware.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/about/view/screens/about_us_screen.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/about/view/screens/privacy_policy_screen.dart';
import 'package:jobodia_frontend/features/applications/view/applications_screen.dart';
import 'package:jobodia_frontend/features/company/view/company_profile_screen.dart';
import 'package:jobodia_frontend/features/auth/view/login_screen.dart';
import 'package:jobodia_frontend/features/auth/view/otp_verification_screen.dart';
import 'package:jobodia_frontend/features/auth/view/reset_password_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_preview_screen.dart';
import 'package:jobodia_frontend/features/home/view/main_shell_screen.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/views/onboarding_view.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/edit_profile_screen.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';
import 'package:jobodia_frontend/features/preferences/view/preferences_wizard_screen.dart';
import 'package:jobodia_frontend/features/report/controller/report_controller.dart';
import 'package:jobodia_frontend/features/report/view/screens/report_screen.dart';
import 'package:jobodia_frontend/features/saved_jobs/view/saved_jobs_screen.dart';
import 'package:jobodia_frontend/features/analytics/view/application_analytics_screen.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/notifications/view/notifications_screen.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';
import 'package:jobodia_frontend/features/settings/view/settings_screen.dart';
import 'package:jobodia_frontend/features/job_alerts/view/job_alerts_screen.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/referrals/view/referral_screen.dart';
import 'package:jobodia_frontend/features/salary/view/salary_screen.dart';
import 'package:jobodia_frontend/features/assessments/view/assessments_screen.dart';
import 'package:jobodia_frontend/features/assessments/view/assessment_quiz_screen.dart';
import 'package:jobodia_frontend/features/messaging/view/conversations_screen.dart';
import 'package:jobodia_frontend/features/messaging/view/conversation_detail_screen.dart';
import 'package:jobodia_frontend/features/company_reviews/view/company_reviews_screen.dart';
import 'package:jobodia_frontend/features/career_goals/view/career_goals_screen.dart';
import 'package:jobodia_frontend/features/market_trends/view/market_trends_screen.dart';

const _defaultDuration = Duration(milliseconds: 250);
const _defaultCurve = Curves.easeOutCubic;

/// Maps route names to pages for GetX navigation.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    // ── Public routes (no auth required) ───────────────────────────
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<OnboardingController>(OnboardingController.new),
      ),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
    ),

    // ── Protected routes (auth required) ───────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<ReportController>(ReportController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cvBuilder,
      page: () => const CvBuilderScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<CvBuilderController>(CvBuilderController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cvPreview,
      page: () => const CvPreviewScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<CvBuilderController>(CvBuilderController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AiChatScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<AiChatController>(AiChatController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.pricing,
      page: () => const PricingScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.jobDetail,
      page: () => const JobDetailScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<JobDetailController>(JobDetailController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<ProfileController>(ProfileController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.savedJobs,
      page: () => const SavedJobsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.applications,
      page: () => ApplicationsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<ProfileController>(ProfileController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.preferencesWizard,
      page: () => const PreferencesWizardScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<PreferencesController>(PreferencesController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.companyProfile,
      page: () => const CompanyProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.applicationAnalytics,
      page: () => const ApplicationAnalyticsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<NotificationsController>(NotificationsController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.jobAlerts,
      page: () => const JobAlertsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<JobAlertController>(JobAlertController.new),
      ),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.referrals,
      page: () => const ReferralScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.salaryInsights,
      page: () => const SalaryScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.assessments,
      page: () => const AssessmentsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.assessmentQuiz,
      page: () => const AssessmentQuizScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.conversations,
      page: () => const ConversationsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.conversationDetail,
      page: () => const ConversationDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.companyReviews,
      page: () => const CompanyReviewsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.careerGoals,
      page: () => const CareerGoalsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.marketTrends,
      page: () => const MarketTrendsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _defaultDuration,
      curve: _defaultCurve,
      middlewares: [AuthMiddleware()],
    ),
  ];
}
