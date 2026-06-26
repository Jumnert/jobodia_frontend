import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';

class PreferencesController extends GetxController {
  PreferencesController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const _prefsKey = 'jobPreferences';
  static const completedKey = 'hasCompletedPreferences';

  final GetStorage _storage;

  final RxInt currentStep = 0.obs;
  final RxString desiredRole = ''.obs;
  final RxString experienceLevel = ''.obs;
  final RxString preferredLocation = ''.obs;

  bool get hasCompletedPreferences => _storage.read<bool>(completedKey) == true;

  static const roles = [
    'Designer',
    'Developer',
    'Product Manager',
    'Marketing',
    'Other',
  ];

  static const levels = [
    'Mid-level',
    'Intermediate',
    'Senior',
    'Expert',
    'Internship',
  ];

  static const locations = ['Remote', 'Singapore', 'Washington, DC', 'Any'];

  void selectRole(String role) => desiredRole.value = role;
  void selectLevel(String level) => experienceLevel.value = level;
  void selectLocation(String location) => preferredLocation.value = location;

  void goBack() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goNext() {
    if (currentStep.value < 2) currentStep.value++;
  }

  void complete() {
    currentStep.value = 0;
    _storage.write(_prefsKey, {
      'desiredRole': desiredRole.value,
      'experienceLevel': experienceLevel.value,
      'preferredLocation': preferredLocation.value,
    });
    _storage.write(completedKey, true);

    // Pre-seed the home feed filters immediately if the controller is live.
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      final level = experienceLevel.value;
      final loc = preferredLocation.value;
      if (level.isNotEmpty) home.selectLevel(level);
      if (loc.isNotEmpty && loc != 'Any') home.selectLocation(loc);
    }

    Get.offAllNamed(AppRoutes.home);
  }
}
