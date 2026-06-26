import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class FaqCard extends StatelessWidget {
  const FaqCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoCard(
      title: 'Questions',
      child: Column(
        children: [
          _FaqItem(
            question: 'Can I cancel anytime?',
            answer:
                'Yes. Plans are mock subscriptions for now, and checkout will be connected later.',
          ),
          _FaqItem(
            question: 'Do I need Pro to browse jobs?',
            answer:
                'No. Starter keeps the core job feed available while Pro unlocks stronger AI tools.',
          ),
          _FaqItem(
            question: 'Will my CV data stay editable?',
            answer:
                'Yes. The builder flow keeps your profile structured so templates can be changed later.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
