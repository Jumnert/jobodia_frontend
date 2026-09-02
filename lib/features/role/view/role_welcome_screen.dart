import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';
import 'package:jobodia_frontend/services/local_profile_photo_store.dart';
import 'package:lottie/lottie.dart';

/// Celebrates the user's role choice before collecting job preferences.
class RoleWelcomeScreen extends StatefulWidget {
  const RoleWelcomeScreen({
    this.previewMode = false,
    this.photoBytes,
    super.key,
  });

  /// Returns to the previous screen after the celebration when opened from
  /// Settings instead of continuing through onboarding.
  final bool previewMode;
  final Uint8List? photoBytes;

  @override
  State<RoleWelcomeScreen> createState() => _RoleWelcomeScreenState();
}

class _RoleWelcomeScreenState extends State<RoleWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final Uint8List? _photoBytes;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.08, 1, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.86, end: 1)
      .animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
      );

  @override
  void initState() {
    super.initState();
    _photoBytes = widget.photoBytes ?? LocalProfilePhotoStore().readPhoto();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'there';
    final avatarUrl = user?.avatarUrl?.trim();
    final initial = name == 'there' ? 'J' : name.substring(0, 1).toUpperCase();
    final selectedRole = Get.find<RoleController>().role.value;
    final role = selectedRole?.labelKey.tr ?? 'role_member_label'.tr;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: palette.scaffold,
        systemNavigationBarIconBrightness: context.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: FScaffold(
        childPad: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: palette.scaffold),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-1.2, -1),
                  end: const Alignment(1.1, 1),
                  stops: const [0, 0.46, 1],
                  colors: [
                    AppColors.brandPrimary.withValues(
                      alpha: context.isDark ? 0.11 : 0.075,
                    ),
                    AppColors.brandTeal.withValues(
                      alpha: context.isDark ? 0.045 : 0.03,
                    ),
                    AppColors.brandPrimary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _WelcomeDotTexture(
                      color: context.isDark
                          ? Colors.white
                          : AppColors.brandPrimary,
                      opacity: context.isDark ? 0.085 : 0.07,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: 0.9,
                    child: Lottie.asset(
                      'assets/animations/nav_icons/Confetti.json',
                      fit: BoxFit.cover,
                      repeat: true,
                      frameRate: const FrameRate(60),
                      renderCache: RenderCache.drawingCommands,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.lerp(
                                      AppColors.brandPrimary,
                                      Colors.white,
                                      0.28,
                                    )!,
                                    AppColors.brandPrimary,
                                    Color.lerp(
                                      AppColors.brandPrimary,
                                      Colors.black,
                                      0.2,
                                    )!,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandPrimary.withValues(
                                      alpha: context.isDark ? 0.2 : 0.14,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: context.isDark ? 0.2 : 0.08,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: palette.surface.withValues(
                                    alpha: 0.96,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: context.isDark ? 0.12 : 0.5,
                                    ),
                                  ),
                                ),
                                child: _photoBytes != null
                                    ? ClipOval(
                                        child: Image.memory(
                                          _photoBytes,
                                          width: 106,
                                          height: 106,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      )
                                    : avatarUrl == null || avatarUrl.isEmpty
                                    ? FAvatar.raw(
                                        size: 106,
                                        child: Text(
                                          initial,
                                          style: theme.typography.display.xl2
                                              .copyWith(
                                                color: palette.textPrimary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      )
                                    : FAvatar(
                                        size: 106,
                                        image: NetworkImage(avatarUrl),
                                        fallback: Text(
                                          initial,
                                          style: theme.typography.display.xl2
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              'welcome_jobodia'.tr,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.lg.copyWith(
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$name!',
                              textAlign: TextAlign.center,
                              style: theme.typography.display.xl3.copyWith(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w900,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                role,
                                style: theme.typography.body.sm.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'welcome_ready'.tr,
                              textAlign: TextAlign.center,
                              style: theme.typography.body.sm.copyWith(
                                color: palette.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    FButton(
                      onPress: () {
                        HapticFeedback.lightImpact();
                        if (widget.previewMode) {
                          Get.back<void>();
                        } else {
                          Get.offNamed<void>(AppRoutes.preferences);
                        }
                      },
                      child: Text('personalize'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeDotTexture extends CustomPainter {
  const _WelcomeDotTexture({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 18.0;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var row = 0; row * spacing < size.height; row++) {
      for (var column = 0; column * spacing < size.width; column++) {
        final variation = (row * 7 + column * 11) % 5;
        final dotOpacity = opacity * (0.45 + variation * 0.12);
        paint.color = color.withValues(alpha: dotOpacity);

        final x = column * spacing + (row.isOdd ? spacing / 2 : 0);
        final y = row * spacing;
        final radius = variation == 0 ? 1.0 : 0.7;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WelcomeDotTexture oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
