import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Static privacy policy information.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: BlurredHeader(
        child: FHeader.nested(
          title: const Text('Privacy & Policy'),
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
        children: [FCard(child: _PrivacyPolicyContent())],
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Policy',
          style: theme.typography.body.lg.copyWith(
            color: theme.colors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This privacy policy applies to the Jobodia app (hereby referred to as '
          '"Application") for mobile devices that was created by (hereby '
          'referred to as "Service Provider") as a Commercial service. This '
          'service is intended for use "AS IS".',
          style: theme.typography.body.sm.copyWith(
            color: palette.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
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
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.foreground,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: theme.typography.body.sm.copyWith(
              color: palette.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
