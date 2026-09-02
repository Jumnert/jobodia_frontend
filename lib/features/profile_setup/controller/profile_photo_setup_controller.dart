import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';
import 'package:jobodia_frontend/services/local_profile_photo_store.dart';

class ProfilePhotoSetupController extends GetxController {
  ProfilePhotoSetupController({
    LocalProfilePhotoStore? store,
    this.previewMode = false,
  }) : _store = store ?? LocalProfilePhotoStore();

  final LocalProfilePhotoStore _store;
  final bool previewMode;

  final Rxn<Uint8List> photoBytes = Rxn<Uint8List>();
  final RxBool isOpeningCamera = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasPhoto => photoBytes.value?.isNotEmpty == true;

  String get firstName {
    if (!Get.isRegistered<AuthController>()) return 'there';
    final name =
        Get.find<AuthController>().currentUser.value?.name.trim() ?? '';
    if (name.isEmpty || name == 'Guest User') return 'there';
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  void onInit() {
    super.onInit();
    if (!previewMode) photoBytes.value = _store.readPhoto();
  }

  Future<void> scanNow(Future<Uint8List?> Function() openCamera) async {
    if (isOpeningCamera.value) return;
    isOpeningCamera.value = true;
    errorMessage.value = '';
    try {
      final bytes = await openCamera();
      if (bytes == null || bytes.isEmpty) return;
      if (!previewMode) await _store.savePhoto(bytes);
      photoBytes.value = bytes;
    } on Object {
      errorMessage.value =
          'The camera is unavailable. Check camera permission and try again.';
    } finally {
      isOpeningCamera.value = false;
    }
  }

  Future<void> continueWithPhoto() async {
    if (previewMode) {
      Get.offNamed<void>(
        AppRoutes.roleWelcome,
        arguments: {'previewMode': true, 'photoBytes': photoBytes.value},
      );
      return;
    }
    await _store.completeSetup();
    _continueAfterPhoto();
  }

  Future<void> skipForNow() async {
    if (previewMode) {
      Get.back<void>();
      return;
    }
    await _store.completeSetup();
    _continueAfterSkip();
  }

  void _continueAfterPhoto() {
    final hasRole = Get.isRegistered<RoleController>()
        ? Get.find<RoleController>().hasRole
        : false;
    Get.offAllNamed(hasRole ? AppRoutes.roleWelcome : AppRoutes.selectRole);
  }

  void _continueAfterSkip() {
    final hasRole = Get.isRegistered<RoleController>()
        ? Get.find<RoleController>().hasRole
        : false;
    Get.offAllNamed(hasRole ? AppRoutes.home : AppRoutes.selectRole);
  }
}
