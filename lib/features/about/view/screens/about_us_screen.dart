import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/feature_card_container.dart';
import 'package:jobodia_frontend/core/widgets/feature_header.dart';

/// Static information about Jobodia.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _subtitle = 'Learn more about the team behind Jobodia';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.headerStart,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const headerHeight = 190.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const FeatureHeader(
                          title: 'About us',
                          subtitle: _subtitle,
                          height: headerHeight,
                        ),
                        FeatureCardContainer(
                          minHeight: constraints.maxHeight - headerHeight,
                          padding: EdgeInsets.fromLTRB(
                            22,
                            22,
                            22,
                            MediaQuery.paddingOf(context).bottom + 32,
                          ),
                          child: const _AboutUsContent(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutUsContent extends StatelessWidget {
  const _AboutUsContent();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      color: context.palette.textSecondary,
      fontSize: 14,
      height: 1.45,
    );

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
          style: bodyStyle,
        ),
        const SizedBox(height: 18),
        const _SectionTitle('What We Offer'),
        const SizedBox(height: 8),
        _BulletText('AI Resume Builder for fast, professional CV creation'),
        _BulletText('Smart Job Matching based on skills and experience'),
        _BulletText('Easy Job Posting and Candidate Management for employers'),
        _BulletText(
          'Real-time communication between job seekers and recruiters',
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Why Jobodia?'),
        const SizedBox(height: 8),
        Text(
          'We combine technology and simplicity to remove the stress from '
          'job searching and hiring, so you can focus on what matters most: '
          'building your future.',
          style: bodyStyle,
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
    return Text(
      text,
      style: TextStyle(
        color: context.palette.textPrimary,
        fontSize: 17,
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
                  color: context.palette.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
