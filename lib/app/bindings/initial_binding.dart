import 'package:get/get.dart';
import 'package:jobodia_frontend/core/services/secure_storage_service.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';

/// Registers app-wide dependencies before the first screen is shown.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SecureStorageService>()) {
      Get.put(SecureStorageService(), permanent: true);
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(const AuthRepository(), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          Get.find<AuthRepository>(),
          Get.find<SecureStorageService>(),
        ),
        permanent: true,
      );
    }
  }
}
