import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart'
    as jobodia_ai;
import 'package:jobodia_frontend/features/home/controller/home_controller.dart'
    as jobodia_home;
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/interview/controller/flashcards_controller.dart';
import 'package:jobodia_frontend/features/interview/controller/interview_schedule_controller.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/pricing/controller/pricing_controller.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:jobodia_frontend/features/search/controller/search_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';
import 'package:jobodia_frontend/features/job_detail/controller/notes_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SecureStorageService(), permanent: true);
    Get.put(const AuthRepository(), permanent: true);
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(NotesController(), permanent: true);
    Get.put(SavedJobsController(), permanent: true);
    Get.put(ApplicationsController(), permanent: true);
    Get.put(PreferencesController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.put(CvBuilderController(), permanent: true);
    Get.put(JobSearchController(), permanent: true);
    Get.put(FlashcardsController(), permanent: true);
    Get.put(PricingController(), permanent: true);
    Get.put(CompanyController(), permanent: true);
    Get.put(InterviewScheduleController(), permanent: true);
    Get.put(JobAlertController(), permanent: true);
    Get.put(FeatureDiscoveryController(), permanent: true);

    Get.lazyPut(() => jobodia_home.HomeController(), fenix: true);
    Get.lazyPut(() => jobodia_ai.AiChatController(), fenix: true);
    // MockInterviewController starts a periodic timer — register lazily in
    // the interview screen, not permanently here.
  }
}
