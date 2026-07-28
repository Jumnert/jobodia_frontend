import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// The per-plan benefits card shown on the pricing screen. Lists the selected
/// plan's [features] as a bulleted column and exposes a call-to-action row for
/// custom requests.
class PricingCard extends StatelessWidget {
  const PricingCard({
    super.key,
    required this.features,
    this.ctaLabel = 'Contact us',
    this.onCtaPressed,
  });

  /// Feature lines rendered as a bulleted list.
  final List<String> features;

  /// Label for the trailing call-to-action button.
  final String ctaLabel;

  /// Called when the call-to-action button is tapped.
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          ...features.map((feature) => _FeatureRow(text: feature)),
          Divider(color: palette.divider, height: 18),
          Row(
            children: [
              Icon(
                FLucideIcons.arrowUpRight,
                color: palette.iconPrimary,
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For custom requests',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onCtaPressed, child: Text(ctaLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF8A8E92),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
