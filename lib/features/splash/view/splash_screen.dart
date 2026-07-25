import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/constants/app_spacing.dart';

/// Brief branded startup layer shown above the app's resolved initial route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.child, this.onFinished, super.key});

  final Widget child;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _displayDuration = Duration(milliseconds: 1900);
  static const _fadeDuration = Duration(milliseconds: 450);

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _hideAfterDelay();
  }

  Future<void> _hideAfterDelay() async {
    await Future<void>.delayed(_displayDuration);
    if (!mounted) return;

    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
      return;
    }

    setState(() => _isVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: _fadeDuration,
          switchOutCurve: Curves.easeInCubic,
          child: _isVisible
              ? const _SplashContent(key: ValueKey('jobodia-splash'))
              : const SizedBox.shrink(key: ValueKey('app-content')),
        ),
      ],
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ColoredBox(
      color: palette.scaffold,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surface, palette.scaffold],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -80,
              child: _AmbientCircle(
                size: 250,
                color: AppColors.brandTeal.withValues(alpha: 0.09),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -100,
              child: _AmbientCircle(
                size: 290,
                color: AppColors.info.withValues(alpha: 0.07),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    TweenAnimationBuilder<double>(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 850),
                      curve: Curves.easeOutBack,
                      tween: Tween(begin: 0.82, end: 1),
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        width: 104,
                        height: 104,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.brandTeal.withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandTeal.withValues(
                                alpha: 0.16,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/branding/jobodia_logo.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Jobodia',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your next move starts here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(flex: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        width: 72,
                        height: 3,
                        child: LinearProgressIndicator(
                          color: AppColors.brandTeal,
                          backgroundColor: AppColors.brandTeal.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
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

class _AmbientCircle extends StatelessWidget {
  const _AmbientCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
