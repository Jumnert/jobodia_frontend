import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  final pages = [
    _WalkthroughPageData(
      title: "Let's explore Jobodia",
      description: "Discover tools to supercharge your career journey.",
      icon: Icons.explore_rounded,
      color: AppColors.brandTeal,
    ),
    _WalkthroughPageData(
      title: "AI Career Assistant",
      description:
          "Get instant career advice, resume reviews, and interview tips from our AI.",
      icon: Icons.smart_toy_rounded,
      color: AppColors.primary,
    ),
    _WalkthroughPageData(
      title: "Build your CV",
      description:
          "Create a professional CV in minutes to stand out to recruiters.",
      icon: Icons.description_rounded,
      color: AppColors.success,
    ),
    _WalkthroughPageData(
      title: "Interview Practice",
      description: "Ace your interviews with flashcards and mock questions.",
      icon: Icons.style_rounded,
      color: AppColors.warning,
    ),
    _WalkthroughPageData(
      title: "Market Insights",
      description:
          "Know your market value and track the most in-demand skills.",
      icon: Icons.insights_rounded,
      color: AppColors.info,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Get.find<FeatureDiscoveryController>().markWalkthroughSeen();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Get.find<FeatureDiscoveryController>().markWalkthroughSeen();
                  Get.back();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final p = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: p.color.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon, color: p.color, size: 60),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.brandTeal
                              : palette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: _currentIndex == pages.length - 1
                        ? "Get Started"
                        : "Next",
                    onPressed: _nextPage,
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

class _WalkthroughPageData {
  _WalkthroughPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
