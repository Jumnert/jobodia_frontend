import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';
import 'package:jobodia_frontend/features/messaging/model/user_qr_code.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

MessagingController _messagingController() =>
    Get.isRegistered<MessagingController>()
    ? Get.find<MessagingController>()
    : Get.put(MessagingController());

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  PublicUserModel? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final user = await _messagingController().fetchCurrentUser();
      if (!mounted) return;
      setState(() => _user = user);
    } on Object {
      if (!mounted) return;
      setState(() => _error = 'Could not load your QR code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _user == null
                  ? _error == null
                        ? const FCircularProgress()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FButton(
                                onPress: _load,
                                child: const Text('Try again'),
                              ),
                            ],
                          )
                  : _QrCard(user: _user!),
            ),
          ),
          Positioned(
            top: top + 14,
            left: 20,
            child: QuietGlassBackButton(onPressed: Get.back),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.user});

  final PublicUserModel user;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'My Jobodia QR',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let another user scan this to open your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: userQrPayload(user.userId),
              version: QrVersions.auto,
              size: 230,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            user.displayName,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          Text(
            '@${user.username}',
            style: TextStyle(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class UserQrScannerScreen extends StatefulWidget {
  const UserQrScannerScreen({super.key});

  @override
  State<UserQrScannerScreen> createState() => _UserQrScannerScreenState();
}

class _UserQrScannerScreenState extends State<UserQrScannerScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handling = false;

  @override
  void dispose() {
    unawaited(_scanner.dispose());
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    final userId = userIdFromQrPayload(raw);
    if (userId == null) {
      _handling = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is not a Jobodia user QR code.')),
        );
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      _handling = false;
      return;
    }

    _handling = true;
    await _scanner.stop();
    try {
      final user = await _messagingController().fetchUser(userId);
      if (!mounted) return;
      Get.offNamed<void>(AppRoutes.publicProfile, arguments: user);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This user could not be found.')),
      );
      _handling = false;
      await _scanner.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera unavailable: ${error.errorDetails?.message ?? error.errorCode.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const _ScannerOverlay(),
          Positioned(
            top: top + 14,
            left: 20,
            child: QuietGlassBackButton(onPressed: Get.back),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 30,
            child: const Text(
              'Place a Jobodia user QR code inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
      ),
    ),
  );
}
