import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/safe_content_padding.dart';
import 'package:jobodia_frontend/features/profile_setup/controller/profile_photo_setup_controller.dart';
import 'package:jobodia_frontend/features/profile_setup/view/profile_selfie_camera_screen.dart';

class ProfilePhotoSetupScreen extends GetView<ProfilePhotoSetupController> {
  const ProfilePhotoSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeContentPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Obx(() {
                  final bytes = controller.photoBytes.value;
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Center(child: _ProfilePhotoVisual(photoBytes: bytes)),
                      const SizedBox(height: 30),
                      Text(
                        bytes == null
                            ? 'Put a face to your name'
                            : 'Looking great, ${controller.firstName}!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 30,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Text(
                          bytes == null
                              ? 'Take a quick selfie so people recognize you across Jobodia.'
                              : 'This photo is ready to use on your Jobodia profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ),
                      Obx(() {
                        final error = controller.errorMessage.value;
                        if (error.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.error,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final hasPhoto = controller.hasPhoto;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: FButton(
                      onPress: controller.isOpeningCamera.value
                          ? null
                          : hasPhoto
                          ? controller.continueWithPhoto
                          : () => _openSelfieCamera(controller),
                      prefix: controller.isOpeningCamera.value
                          ? const FCircularProgress()
                          : Icon(
                              hasPhoto
                                  ? FLucideIcons.arrowRight
                                  : FLucideIcons.scanFace,
                              size: 18,
                            ),
                      child: Text(
                        controller.isOpeningCamera.value
                            ? 'Opening camera'
                            : hasPhoto
                            ? 'Continue'
                            : 'Scan now',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FButton(
                    variant: FButtonVariant.secondary,
                    onPress: hasPhoto
                        ? () {
                            HapticFeedback.lightImpact();
                            _openSelfieCamera(controller);
                          }
                        : controller.skipForNow,
                    child: Text(hasPhoto ? 'Retake photo' : 'Skip for now'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _openSelfieCamera(ProfilePhotoSetupController controller) {
    return controller.scanNow(
      () =>
          Get.to<Uint8List>(() => const ProfileSelfieCameraScreen()) ??
          Future<Uint8List?>.value(),
    );
  }
}

class _ProfilePhotoVisual extends StatelessWidget {
  const _ProfilePhotoVisual({this.photoBytes});

  final Uint8List? photoBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes;
    if (bytes == null) {
      return SizedBox(
        width: 280,
        height: 280,
        child: Image.asset(
          'assets/images/profile/profile_selfie_setup.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return Container(
      width: 250,
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.18),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
