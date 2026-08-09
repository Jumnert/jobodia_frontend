import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const _pages = <_WalkthroughPageData>[
    _WalkthroughPageData(
      eyebrow: 'walkthrough_eyebrow_welcome',
      title: 'walkthrough_title_welcome',
      description: 'walkthrough_desc_welcome',
      icon: FLucideIcons.compass,
      color: AppColors.brandTeal,
      highlights: [
        'walkthrough_highlight_jobs',
        'walkthrough_highlight_growth',
      ],
    ),
    _WalkthroughPageData(
      eyebrow: 'walkthrough_eyebrow_ai',
      title: 'walkthrough_title_ai',
      description: 'walkthrough_desc_ai',
      icon: FLucideIcons.bot,
      color: AppColors.brandTeal,
      highlights: [
        'walkthrough_highlight_guidance',
        'walkthrough_highlight_steps',
      ],
    ),
    _WalkthroughPageData(
      eyebrow: 'walkthrough_eyebrow_cv',
      title: 'walkthrough_title_cv',
      description: 'walkthrough_desc_cv',
      icon: FLucideIcons.fileText,
      color: AppColors.info,
      highlights: [
        'walkthrough_highlight_builder',
        'walkthrough_highlight_professional',
      ],
    ),
    _WalkthroughPageData(
      eyebrow: 'walkthrough_eyebrow_interview',
      title: 'walkthrough_title_interview',
      description: 'walkthrough_desc_interview',
      icon: FLucideIcons.bookOpen,
      color: AppColors.warning,
      highlights: [
        'walkthrough_highlight_practice',
        'walkthrough_highlight_confidence',
      ],
    ),
    _WalkthroughPageData(
      eyebrow: 'walkthrough_eyebrow_insights',
      title: 'walkthrough_title_insights',
      description: 'walkthrough_desc_insights',
      icon: FLucideIcons.chartLine,
      color: AppColors.brandTeal,
      highlights: [
        'walkthrough_highlight_market',
        'walkthrough_highlight_skills',
      ],
    ),
  ];

  bool get _isFirstPage => _currentIndex == 0;
  bool get _isLastPage => _currentIndex == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    Get.find<FeatureDiscoveryController>().markWalkthroughSeen();
    Get.back<void>();
  }

  Future<void> _nextPage() async {
    HapticFeedback.selectionClick();
    if (_isLastPage) {
      _finish();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _previousPage() async {
    if (_isFirstPage) return;
    HapticFeedback.selectionClick();
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${(_currentIndex + 1).toString().padLeft(2, '0')} / ${_pages.length.toString().padLeft(2, '0')}',
                      style: theme.typography.body.xs.copyWith(
                        color: AppColors.brandTeal,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: _finish,
                    child: Text('skip'.tr),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() {
                  _currentIndex = index;
                }),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _WalkthroughPage(
                  data: _pages[index],
                  active: index == _currentIndex,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Column(
                children: [
                  _ProgressIndicator(
                    count: _pages.length,
                    currentIndex: _currentIndex,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      if (!_isFirstPage) ...[
                        Expanded(
                          child: FButton(
                            variant: FButtonVariant.outline,
                            onPress: _previousPage,
                            prefix: const Icon(
                              FLucideIcons.arrowLeft,
                              size: 18,
                            ),
                            child: Text('back'.tr),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        flex: _isFirstPage ? 2 : 1,
                        child: FButton(
                          onPress: _nextPage,
                          suffix: Icon(
                            _isLastPage
                                ? FLucideIcons.check
                                : FLucideIcons.arrowRight,
                            size: 18,
                          ),
                          child: Text(
                            _isLastPage ? 'start_exploring'.tr : 'next'.tr,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughPage extends StatelessWidget {
  const _WalkthroughPage({required this.data, required this.active});

  final _WalkthroughPageData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = FTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 510;
        final visualSize = compact ? 56.0 : 64.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: active ? 1 : 0.96,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: _FeatureVisual(
                  icon: data.icon,
                  color: data.color,
                  size: visualSize,
                ),
              ),
              SizedBox(height: compact ? 18 : 22),
              Text(
                data.eyebrow.tr,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  color: data.color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.title.tr,
                textAlign: TextAlign.center,
                style: theme.typography.display.lg.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 13),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Text(
                  data.description.tr,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.md.copyWith(
                    color: palette.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: compact ? 16 : 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: data.highlights
                    .map(
                      (highlight) => _FeatureHighlight(
                        label: highlight,
                        color: data.color,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureVisual extends StatelessWidget {
  const _FeatureVisual({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  const _FeatureHighlight({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FLucideIcons.check, color: color, size: 15),
        const SizedBox(width: 5),
        Text(
          label.tr,
          style: theme.typography.body.sm.copyWith(
            color: context.palette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final active = index <= currentIndex;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            height: 4,
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.brandTeal : context.palette.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _WalkthroughPageData {
  const _WalkthroughPageData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.highlights,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> highlights;
}
