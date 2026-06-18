import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

/// Registers dependencies used by the auth feature.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(const AuthRepository(), permanent: true);
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}
