import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/feature_card_container.dart';
import 'package:jobodia_frontend/core/widgets/feature_header.dart';

/// Static privacy policy information.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _subtitle = 'enter your Email address to start password reset';

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
                          title: 'Privacy & Policy',
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
                          child: const _PrivacyPolicyContent(),
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

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'This privacy policy applies to the daw app (hereby referred to as '
          '"Application") for mobile devices that was created by (hereby '
          'referred to as "Service Provider") as a Commercial service. This '
          'service is intended for use "AS IS".',
          style: _bodyStyle,
        ),
        SizedBox(height: 18),
        _PolicyQuestion(
          title:
              'What information does the Application obtain and how is it used?',
          body:
              'The Application may collect information you provide when using '
              'its features, such as account details, feedback, and technical '
              'information needed to improve the service.',
        ),
        _PolicyQuestion(
          title:
              'Does the Application collect precise real time location information of the device?',
          body:
              'This Application does not collect precise real-time location '
              'information from your mobile device.',
        ),
        _PolicyQuestion(
          title:
              'Do third parties see and/or have access to information obtained by the Application?',
          body:
              'Only aggregated or necessary information may be shared with '
              'trusted service providers that help operate and improve the '
              'Application. Information is not sold to third parties.',
        ),
        _PolicyQuestion(
          title: 'What are my opt-out rights?',
          body:
              'You can stop all collection of information by uninstalling the '
              'Application. You may also contact the Service Provider to ask '
              'about access, correction, or deletion of your information.',
        ),
        _PolicyQuestion(
          title: 'Data Retention Policy',
          body:
              'Information is retained only for as long as needed to provide '
              'the service, meet legal requirements, and resolve disputes.',
        ),
        _PolicyQuestion(
          title: 'Security',
          body:
              'Reasonable safeguards are used to protect your information. '
              'However, no electronic storage or transmission method can be '
              'guaranteed to be completely secure.',
        ),
      ],
    );
  }
}

class _PolicyQuestion extends StatelessWidget {
  const _PolicyQuestion({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(body, style: _bodyStyle),
        ],
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 14,
  height: 1.45,
);
