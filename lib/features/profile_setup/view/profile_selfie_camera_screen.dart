import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A branded, in-app camera with a face-shaped guide for profile selfies.
class ProfileSelfieCameraScreen extends StatefulWidget {
  const ProfileSelfieCameraScreen({super.key});

  @override
  State<ProfileSelfieCameraScreen> createState() =>
      _ProfileSelfieCameraScreenState();
}

class _ProfileSelfieCameraScreenState extends State<ProfileSelfieCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCameras());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_disposeCamera());
    } else if (state == AppLifecycleState.resumed && _cameras.isNotEmpty) {
      unawaited(_initializeCamera(_cameraIndex));
    }
  }

  Future<void> _initializeCameras() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera was found on this device.');
        return;
      }
      _cameras = cameras;
      final frontIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _cameraIndex = frontIndex < 0 ? 0 : frontIndex;
      await _initializeCamera(_cameraIndex);
    } on CameraException catch (error) {
      _showCameraError(error);
    } on Object {
      _showCameraError();
    }
  }

  Future<void> _initializeCamera(int index) async {
    await _disposeCamera();
    if (!mounted || _cameras.isEmpty) return;

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _cameraController = controller;
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (mounted) {
        setState(() {
          _cameraIndex = index;
          _errorMessage = null;
        });
      }
    } on CameraException catch (error) {
      await controller.dispose();
      if (identical(_cameraController, controller)) _cameraController = null;
      _showCameraError(error);
    } on Object {
      await controller.dispose();
      if (identical(_cameraController, controller)) _cameraController = null;
      _showCameraError();
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    await controller?.dispose();
  }

  void _showCameraError([CameraException? error]) {
    if (!mounted) return;
    final denied =
        error?.code == 'CameraAccessDenied' ||
        error?.code == 'CameraAccessDeniedWithoutPrompt';
    setState(() {
      _errorMessage = denied
          ? 'Camera access is needed to take your profile selfie.'
          : 'The camera could not start. Please try again.';
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    HapticFeedback.selectionClick();
    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    await _initializeCamera(nextIndex);
  }

  Future<void> _capture() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isCapturing) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isCapturing = true);
    try {
      final photo = await controller.takePicture();
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      Get.back<Uint8List>(result: bytes);
    } on CameraException catch (error) {
      _showCameraError(error);
      if (mounted) setState(() => _isCapturing = false);
    } on Object {
      _showCameraError();
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final isReady = controller?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isReady)
            _CameraPreviewFill(controller: controller!)
          else
            const _CameraLoading(),
          if (isReady)
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _FaceGuidePainter()),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CameraControl(
                        tooltip: 'Close camera',
                        icon: FLucideIcons.x,
                        onPressed: () => Get.back<void>(),
                      ),
                      if (_cameras.length > 1)
                        _CameraControl(
                          tooltip: 'Switch camera',
                          icon: FLucideIcons.switchCamera,
                          onPressed: _switchCamera,
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Center your face',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep your eyes inside the frame and use even lighting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.66),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: _initializeCameras,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            icon: const Icon(FLucideIcons.rotateCcw, size: 17),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  Semantics(
                    button: true,
                    label: 'Take selfie',
                    child: GestureDetector(
                      onTap: isReady && !_isCapturing ? _capture : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isReady
                                ? AppColors.brandPrimary
                                : Colors.white38,
                          ),
                          child: _isCapturing
                              ? const Padding(
                                  padding: EdgeInsets.all(19),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(
                                  FLucideIcons.camera,
                                  color: Colors.white,
                                  size: 27,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Tap to take photo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewFill extends StatelessWidget {
  const _CameraPreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    var scale = screenSize.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}

class _CameraLoading extends StatelessWidget {
  const _CameraLoading();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF07111F),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.brandPrimary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _CameraControl extends StatelessWidget {
  const _CameraControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.38),
        foregroundColor: Colors.white,
        minimumSize: const Size.square(48),
      ),
      icon: Icon(icon, size: 21),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final guideWidth = (size.width * 0.76).clamp(260.0, 340.0);
    final guideHeight = guideWidth * 1.28;
    final guide = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.48),
      width: guideWidth,
      height: guideHeight,
    );

    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(guide);
    canvas.drawPath(
      shade,
      Paint()..color = Colors.black.withValues(alpha: 0.52),
    );

    canvas.drawOval(
      guide,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final accentPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final start in const [0.15, 1.72, 3.29, 4.86]) {
      canvas.drawArc(guide, start, 0.55, false, accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) => false;
}
