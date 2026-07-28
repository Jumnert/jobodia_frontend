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
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [FCard(child: _AboutUsContent())],
      ),
    );
  }
}

class _AboutUsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 18),
        _SectionTitle('What We Offer'),
        const SizedBox(height: 8),
        _BulletText('AI Resume Builder for fast, professional CV creation'),
        _BulletText('Smart Job Matching based on skills and experience'),
        _BulletText('Easy Job Posting and Candidate Management for employers'),
        _BulletText(
          'Real-time communication between job seekers and recruiters',
        ),
        const SizedBox(height: 18),
        _SectionTitle('Why Jobodia?'),
        const SizedBox(height: 8),
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

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: SizedBox.square(
              dimension: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.typography.body.sm.copyWith(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
