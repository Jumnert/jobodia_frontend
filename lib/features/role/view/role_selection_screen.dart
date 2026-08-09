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
                title: Text('your_role'.tr),
                prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
              ),
            )
          : null,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    compact ? 4 : 10,
                    24,
                    compact ? 8 : 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        image: true,
                        label: 'Role selection illustration',
                        child: RepaintBoundary(
                          child: Image.asset(
                            'assets/images/onboarding/role_selection_hero.png',
                            height: compact ? 154 : 184,
                            fit: BoxFit.contain,
                            cacheHeight: 552,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      Text(
                        'select_your_role'.tr,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.xl2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colors.foreground,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'choose_role_subtitle'.tr,
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.15,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(height: compact ? 10 : 16),
                      Obx(
                        () => _RoleCard(
                          icon: FLucideIcons.userSearch,
                          role: UserRole.jobSeeker,
                          selected: controller.role.value == UserRole.jobSeeker,
                          onTap: () => _choose(controller, UserRole.jobSeeker),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => _RoleCard(
                          icon: FLucideIcons.building2,
                          role: UserRole.employer,
                          selected: controller.role.value == UserRole.employer,
                          onTap: () => _choose(controller, UserRole.employer),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => FButton(
                          onPress: controller.hasRole
                              ? () => _continue(controller)
                              : null,
                          child: Text('next'.tr),
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        'role_settings_hint'.tr,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
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
    Get.offNamed<void>(AppRoutes.roleWelcome);
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
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    final accent = AppColors.brandTeal;
    final deepAccent = Color.lerp(accent, Colors.black, 0.8)!;
    final midAccent = Color.lerp(accent, Colors.black, 0.42)!;
    final lightAccent = Color.lerp(accent, Colors.white, 0.18)!;
    const transitionDuration = Duration(milliseconds: 280);
    const transitionCurve = Curves.easeOutCubic;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: transitionDuration,
        curve: transitionCurve,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [deepAccent, deepAccent, midAccent, lightAccent]
                : [colors.card, colors.card, colors.card, colors.card],
            stops: const [0, 0.42, 0.74, 1],
          ),
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
              : const [],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -62,
              right: -28,
              child: AnimatedOpacity(
                duration: transitionDuration,
                curve: transitionCurve,
                opacity: selected ? 1 : 0,
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
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: transitionDuration,
                curve: transitionCurve,
                opacity: selected ? 1 : 0,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: const _RoleCardNoise(color: AppColors.brandTeal),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: transitionDuration,
                    curve: transitionCurve,
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.transparent,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        key: ValueKey(selected),
                        size: 20,
                        color: selected ? Colors.white : colors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: transitionDuration,
                          curve: transitionCurve,
                          style: theme.typography.body.lg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : colors.foreground,
                            height: isKhmer ? 1 : 1.15,
                          ),
                          child: Text(role.headlineKey.tr),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: transitionDuration,
                          curve: transitionCurve,
                          style: theme.typography.body.xs.copyWith(
                            color: selected
                                ? Color.lerp(Colors.white, lightAccent, 0.38)!
                                : colors.mutedForeground,
                            height: isKhmer ? 1.12 : 1.18,
                          ),
                          child: Text(role.descriptionKey.tr),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: selected
                        ? const Icon(
                            FLucideIcons.circleCheck,
                            key: ValueKey('selected'),
                            size: 20,
                            color: Colors.white,
                          )
                        : const SizedBox(
                            key: ValueKey('unselected'),
                            width: 20,
                            height: 20,
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
