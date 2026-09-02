import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/extensions/context_extensions.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/social_login_section.dart';

/// Shared clean, theme-aware layout used by the login and registration routes.
class AuthScene extends StatelessWidget {
  const AuthScene({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.socialLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final String socialLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: palette.scaffold,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Jobodia',
                      style: FTheme.of(context).typography.body.lg.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      title,
                      style: FTheme.of(context).typography.display.lg.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: FTheme.of(context).typography.body.sm.copyWith(
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SocialLoginSection(title: socialLabel),
                    const SizedBox(height: 22),
                    form,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
