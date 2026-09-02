import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// Anchors for the first-time feature hint shown above the main navigation.
///
/// Keeping these keys outside the navigation widget lets the overlay measure
/// the real control the user should use, rather than showing a mock version.
abstract final class FeatureTourTargets {
  static final postJob = GlobalKey(debugLabel: 'feature-tour-post-job');
  static final aiAssistant = GlobalKey(debugLabel: 'feature-tour-ai-assistant');
}

/// A short, role-aware first-time hint that spotlights one useful action.
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  Rect? _targetBounds;
  late final _FeatureTourData _feature = _FeatureTourData.forCurrentRole();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTarget());
  }

  void _measureTarget([int attempt = 0]) {
    if (!mounted) return;

    final renderObject = _feature.targetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      setState(
        () => _targetBounds =
            renderObject.localToGlobal(Offset.zero) & renderObject.size,
      );
      return;
    }

    // The navigation can still be laying out when this dialog first opens.
    if (attempt < 12) {
      Future<void>.delayed(
        const Duration(milliseconds: 100),
        () => _measureTarget(attempt + 1),
      );
    }
  }

  void _finish() {
    HapticFeedback.selectionClick();
    Get.find<FeatureDiscoveryController>().markWalkthroughSeen();
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = FTheme.of(context);
    final size = MediaQuery.sizeOf(context);
    final target = _targetBounds;
    final spotlight = target?.inflate(8);
    final cardBottom = target == null
        ? 116.0
        : (size.height - target.top + 18).clamp(96.0, size.height - 230.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CustomPaint(
                painter: _SpotlightBarrierPainter(
                  spotlight: spotlight,
                  opacity: 0.78 * value,
                ),
              ),
            ),
          ),
          if (spotlight != null)
            Positioned(
              left: spotlight.left,
              top: spotlight.top,
              width: spotlight.width,
              height: spotlight.height,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.68),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: cardBottom,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.94, end: 1),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(scale: value, child: child),
              ),
              child: Material(
                color: palette.surface,
                elevation: 0,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _feature.title.tr,
                        style: theme.typography.display.md.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _feature.description.tr,
                        style: theme.typography.body.sm.copyWith(
                          color: palette.textSecondary,
                          height: 1.42,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FButton(
                          onPress: _finish,
                          child: Text('feature_tour_got_it'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTourData {
  const _FeatureTourData({
    required this.targetKey,
    required this.title,
    required this.description,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;

  factory _FeatureTourData.forCurrentRole() {
    final isEmployer =
        Get.isRegistered<RoleController>() &&
        Get.find<RoleController>().role.value == UserRole.employer;

    return isEmployer
        ? _FeatureTourData(
            targetKey: FeatureTourTargets.postJob,
            title: 'feature_tour_employer_title',
            description: 'feature_tour_employer_description',
          )
        : _FeatureTourData(
            targetKey: FeatureTourTargets.aiAssistant,
            title: 'feature_tour_job_seeker_title',
            description: 'feature_tour_job_seeker_description',
          );
  }
}

class _SpotlightBarrierPainter extends CustomPainter {
  const _SpotlightBarrierPainter({
    required this.spotlight,
    required this.opacity,
  });

  final Rect? spotlight;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.saveLayer(area, Paint());
    canvas.drawRect(
      area,
      Paint()..color = Colors.black.withValues(alpha: opacity),
    );

    if (spotlight case final hole?) {
      final roundedHole = RRect.fromRectAndRadius(
        hole,
        const Radius.circular(18),
      );
      canvas.drawRRect(roundedHole, Paint()..blendMode = BlendMode.clear);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightBarrierPainter oldDelegate) =>
      oldDelegate.spotlight != spotlight || oldDelegate.opacity != opacity;
}
