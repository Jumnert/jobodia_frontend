import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// Shown after sign up (and re-openable from Settings) so the user picks
/// whether they use Jobodia as a Job Seeker or an Employer.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.preview = false});

  /// When true the screen was opened from Settings to change an existing role,
  /// so it pops back instead of continuing into the app.
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoleController>();
    final theme = FTheme.of(context);

    return FScaffold(
      header: preview
          ? BlurredHeader(
              child: FHeader.nested(
                title: const Text('Your role'),
                prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
              ),
            )
          : null,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          FLucideIcons.users,
                          size: 48,
                          color: theme.colors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select Your Role',
                          textAlign: TextAlign.center,
                          style: theme.typography.body.xl2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Choose how you'd like to use Jobodia.",
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => _RoleCard(
                            icon: FLucideIcons.userSearch,
                            role: UserRole.jobSeeker,
                            selected:
                                controller.role.value == UserRole.jobSeeker,
                            onTap: () =>
                                _choose(controller, UserRole.jobSeeker),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => _RoleCard(
                            icon: FLucideIcons.building2,
                            role: UserRole.employer,
                            selected:
                                controller.role.value == UserRole.employer,
                            onTap: () => _choose(controller, UserRole.employer),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => FButton(
                            onPress: controller.hasRole
                                ? () => _continue(controller)
                                : null,
                            child: const Text('Next'),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text.rich(
                          TextSpan(
                            text: 'You can switch roles anytime in ',
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            children: [
                              TextSpan(
                                text: 'settings.',
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _choose(RoleController controller, UserRole role) {
    HapticFeedback.selectionClick();
    controller.selectRole(role);
    if (preview) {
      Get.back<void>();
    }
  }

  void _continue(RoleController controller) {
    if (!controller.hasRole) return;
    HapticFeedback.lightImpact();
    Get.offAllNamed<void>(AppRoutes.home);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final accent = AppColors.brandTeal;
    final deepAccent = Color.lerp(accent, Colors.black, 0.8)!;
    final midAccent = Color.lerp(accent, Colors.black, 0.42)!;
    final lightAccent = Color.lerp(accent, Colors.white, 0.18)!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected ? null : colors.card,
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    deepAccent,
                    deepAccent,
                    midAccent,
                    lightAccent,
                  ],
                  stops: const [0, 0.42, 0.74, 1],
                )
              : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.72)
                : colors.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (selected) ...[
              Positioned(
                top: -62,
                right: -28,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        midAccent.withValues(alpha: 0.78),
                        midAccent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: const _RoleCardNoise(color: AppColors.brandTeal),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: selected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            )
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected ? Colors.white : colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          role.headline,
                          style: theme.typography.body.lg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : colors.foreground,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          FLucideIcons.circleCheck,
                          size: 20,
                          color: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: theme.typography.body.sm.copyWith(
                      color: selected
                          ? Color.lerp(Colors.white, lightAccent, 0.38)!
                          : colors.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCardNoise extends CustomPainter {
  const _RoleCardNoise({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.075);
    var seed = 17;

    for (var index = 0; index < 90; index++) {
      seed = (seed * 1_103_515_245 + 12_345) & 0x7fffffff;
      final x = (seed % 10_000) / 10_000 * size.width;
      seed = (seed * 1_103_515_245 + 12_345) & 0x7fffffff;
      final y = (seed % 10_000) / 10_000 * size.height;
      canvas.drawCircle(Offset(x, y), index.isEven ? 0.7 : 0.45, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoleCardNoise oldDelegate) =>
      oldDelegate.color != color;
}
