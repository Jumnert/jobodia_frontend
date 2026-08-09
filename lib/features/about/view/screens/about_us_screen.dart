import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Static information about Jobodia.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: BlurredHeader(
        child: FHeader.nested(
          title: const Text('About us'),
          prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: const [_AboutUsContent()],
      ),
    );
  }
}

class _AboutUsContent extends StatelessWidget {
  const _AboutUsContent();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  FLucideIcons.briefcaseBusiness,
                  size: 34,
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Jobodia',
                style: theme.typography.display.sm.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Smarter careers. Better connections.',
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Divider(color: palette.divider),
        const SizedBox(height: 24),
        const _SectionTitle('Our mission'),
        const SizedBox(height: 9),
        Text(
          'Jobodia is an AI-powered career platform built to connect job '
          'seekers and employers in a smarter, faster way. We help job '
          'seekers create professional resumes using AI, discover relevant '
          'job opportunities, and prepare for their next career move with '
          'confidence. At the same time, we give employers powerful tools to '
          'find, evaluate, and connect with the right talent efficiently. '
          'Our mission is simple: make hiring and job searching easier, more '
          'personalized, and more effective for everyone.',
          style: theme.typography.body.sm.copyWith(
            color: palette.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('What we offer'),
        const SizedBox(height: 14),
        const _FeatureRow(
          icon: FLucideIcons.fileUser,
          title: 'AI resume builder',
          description: 'Create a polished, professional CV faster.',
        ),
        const _FeatureRow(
          icon: FLucideIcons.wandSparkles,
          title: 'Smart job matching',
          description: 'Discover roles based on your skills and experience.',
        ),
        const _FeatureRow(
          icon: FLucideIcons.usersRound,
          title: 'Simple hiring tools',
          description: 'Post jobs and manage candidates in one place.',
        ),
        const _FeatureRow(
          icon: FLucideIcons.messagesSquare,
          title: 'Direct communication',
          description: 'Connect job seekers and recruiters effortlessly.',
        ),
        const SizedBox(height: 12),
        const _SectionTitle('Why Jobodia?'),
        const SizedBox(height: 9),
        Text(
          'We combine technology and simplicity to remove the stress from '
          'job searching and hiring, so you can focus on what matters most: '
          'building your future.',
          style: theme.typography.body.sm.copyWith(
            color: palette.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Text(
      text,
      style: theme.typography.body.lg.copyWith(
        color: theme.colors.foreground,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: theme.colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.body.sm.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: theme.typography.body.sm.copyWith(
                    color: palette.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
