import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const _barHeight = 6.0;
const _barBorderRadius = 3.0;
const _titleFontSize = 18.0;
const _percentFontSize = 15.0;
const _dimensionLabelFontSize = 14.0;
const _dimensionPercentFontSize = 13.0;
const _sublabelFontSize = 12.0;
const _descriptionFontSize = 13.0;
const _percentBadgeHPad = 10.0;
const _percentBadgeVPad = 5.0;
const _percentBadgeRadius = 8.0;
const _dragHandleWidth = 40.0;
const _dragHandleHeight = 4.0;
const _animationDurationMs = 700;

/// Bottom sheet showing a breakdown of the match score for a job.
/// All scores are derived from feed-model fields — no new model fields.
class MatchBreakdownSheet extends StatelessWidget {
  const MatchBreakdownSheet({
    required this.matchPercent,
    required this.tags,
    required this.location,
    required this.level,
    super.key,
  });

  final int matchPercent;
  final List<String> tags;
  final String location;
  final String level;

  // ---------------------------------------------------------------------------
  // Dimension derivations per spec
  // ---------------------------------------------------------------------------

  double get _skillsScore => (tags.length / 4.0).clamp(0.0, 1.0);

  double get _locationScore => location == 'Remote' ? 1.0 : 0.75;

  double get _experienceScore {
    switch (level.toLowerCase()) {
      case 'senior':
      case 'expert':
        return 1.0;
      case 'intermediate':
      case 'mid-level':
        return 0.8;
      case 'internship':
        return 0.5;
      default:
        return 0.7;
    }
  }

  double get _salaryScore => (matchPercent / 100.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final dimensions = [
      _MatchDimension(
        label: 'Skills match',
        sublabel: '${tags.length} of 4+ required skills',
        score: _skillsScore,
      ),
      _MatchDimension(
        label: 'Location match',
        sublabel: location == 'Remote'
            ? 'Fully remote position'
            : 'On-site / hybrid',
        score: _locationScore,
      ),
      _MatchDimension(
        label: 'Experience level',
        sublabel: level,
        score: _experienceScore,
      ),
      _MatchDimension(
        label: 'Salary range',
        sublabel: 'Based on overall match',
        score: _salaryScore,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.paddingOf(context).bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: _dragHandleWidth,
              height: _dragHandleHeight,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Why this match?',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _percentBadgeHPad,
                  vertical: _percentBadgeVPad,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(_percentBadgeRadius),
                  border: Border.all(
                    color: AppColors.brandTeal.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '$matchPercent%',
                  style: const TextStyle(
                    color: AppColors.brandTeal,
                    fontSize: _percentFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Based on your profile and job details.',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: _descriptionFontSize,
            ),
          ),
          const SizedBox(height: 24),
          ...dimensions.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _DimensionRow(dimension: d, palette: palette),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchDimension {
  const _MatchDimension({
    required this.label,
    required this.sublabel,
    required this.score,
  });

  final String label;
  final String sublabel;

  /// 0.0 – 1.0
  final double score;
}

class _DimensionRow extends StatefulWidget {
  const _DimensionRow({required this.dimension, required this.palette});

  final _MatchDimension dimension;
  final AppPalette palette;

  @override
  State<_DimensionRow> createState() => _DimensionRowState();
}

class _DimensionRowState extends State<_DimensionRow> {
  @override
  Widget build(BuildContext context) {
    final pct = (widget.dimension.score * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.dimension.label,
              style: TextStyle(
                color: widget.palette.textPrimary,
                fontSize: _dimensionLabelFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                color: AppColors.brandTeal,
                fontSize: _dimensionPercentFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          widget.dimension.sublabel,
          style: TextStyle(
            fontSize: _sublabelFontSize,
            color: widget.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: widget.dimension.score),
          duration: const Duration(milliseconds: _animationDurationMs),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => ClipRRect(
            borderRadius: BorderRadius.circular(_barBorderRadius),
            child: LinearProgressIndicator(
              value: value,
              minHeight: _barHeight,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.brandTeal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
