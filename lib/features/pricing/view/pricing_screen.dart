import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'widgets/selected_plan_card.dart';
import 'widgets/faq_card.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  BillingCycle _billingCycle = BillingCycle.monthly;
  int _selectedPlanIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plans = _plans(yearly: _billingCycle == BillingCycle.yearly);
    final selectedPlan = plans[_selectedPlanIndex];

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
          children: [
            const _PageHeader(),
            const SizedBox(height: 16),
            const _HeroBanner(),
            const SizedBox(height: 16),
            const _FeatureTiles(),
            const SizedBox(height: 18),
            PricingPlanTabs(
              plans: plans,
              selectedIndex: _selectedPlanIndex,
              onChanged: (index) => setState(() => _selectedPlanIndex = index),
            ),
            const SizedBox(height: 16),
            SelectedPlanCard(
              plan: selectedPlan,
              billingCycle: _billingCycle,
              onBillingChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _billingCycle = value);
              },
            ),
            const SizedBox(height: 14),
            _BenefitPanel(plan: selectedPlan),
            const SizedBox(height: 16),
            const FaqCard(),
          ],
        ),
      ),
    );
  }

  List<PricingPlan> _plans({required bool yearly}) {
    return [
      PricingPlan(
        name: 'Starter',
        tabLabel: 'Free',
        price: '0',
        period: 'forever',
        description: 'Start your job search with core tools and a clean CV.',
        cta: 'Get started',
        icon: Icons.rocket_launch_outlined,
        delivery: 'Currently In Use',
        features: const [
          'Browse recommended jobs',
          'Save up to 5 jobs',
          'Basic CV builder templates',
          'Mock AI chat replies',
        ],
      ),
      PricingPlan(
        name: 'Pro',
        tabLabel: 'Pro',
        price: yearly ? '79' : '8',
        period: yearly ? 'year' : 'month',
        description: 'Upgrade your CV, cover letters, and interview prep.',
        cta: 'Upgrade now',
        icon: Icons.workspace_premium_outlined,
        delivery: 'Best value',
        features: const [
          'Unlimited saved jobs',
          'Advanced AI CV generation',
          'Cover letter drafts',
          'Priority job matching',
        ],
      ),
      PricingPlan(
        name: 'Career Plus',
        tabLabel: 'Plus',
        price: yearly ? '149' : '15',
        period: yearly ? 'year' : 'month',
        description: 'Get a guided plan from profile setup to interviews.',
        cta: 'Choose Plus',
        icon: Icons.school_outlined,
        delivery: 'Full guidance',
        features: const [
          'Everything in Pro',
          'Personalized skill roadmap',
          'Portfolio feedback checklist',
          'Weekly application plan',
        ],
      ),
    ];
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: Get.back,
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
        ),
        const Expanded(
          child: Text(
            'Pricing Plan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F11),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TinyPill(text: 'Jobodia Premium', dark: true),
          SizedBox(height: 18),
          Text(
            'Access Premium\nFeatures on Every Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Choose the plan that fits your job search and career growth.',
            style: TextStyle(
              color: Color(0xFFCACDD0),
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTiles extends StatelessWidget {
  const _FeatureTiles();

  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureTileData(Icons.description_outlined, 'CV Builder'),
      _FeatureTileData(Icons.smart_toy_outlined, 'AI Coach'),
      _FeatureTileData(Icons.calendar_month_outlined, 'Roadmap'),
    ];

    return Row(
      children: features
          .map(
            (feature) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _FeatureTile(feature: feature),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _FeatureTileData feature;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(feature.icon, color: palette.iconPrimary, size: 22),
          const SizedBox(height: 8),
          Text(
            feature.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PricingPlanTabs extends StatelessWidget {
  const PricingPlanTabs({
    super.key,
    required this.plans,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<PricingPlan> plans;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Align(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            plans.length,
            (index) => GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? palette.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plans[index].tabLabel,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? palette.scaffold
                        : palette.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitPanel extends StatelessWidget {
  const _BenefitPanel({required this.plan});

  final PricingPlan plan;

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
          ...plan.features.map((feature) => _FeatureRow(text: feature)),
          Divider(color: palette.divider, height: 18),
          Row(
            children: [
              Icon(
                Icons.arrow_outward_rounded,
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
              TextButton(
                onPressed: () => _showContactSheet(context),
                child: const Text('Contact us'),
              ),
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

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.text, this.dark = false});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? Colors.black : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark ? Colors.black : Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FeatureTileData {
  const _FeatureTileData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class PricingPlan {
  const PricingPlan({
    required this.name,
    required this.tabLabel,
    required this.price,
    required this.period,
    required this.description,
    required this.cta,
    required this.icon,
    required this.delivery,
    required this.features,
  });

  final String name;
  final String tabLabel;
  final String price;
  final String period;
  final String description;
  final String cta;
  final IconData icon;
  final String delivery;
  final List<String> features;
}

void _showContactSheet(BuildContext context) {
  final palette = context.palette;
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 40,
            color: AppColors.brandTeal,
          ),
          const SizedBox(height: 16),
          Text(
            'Contact Us',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reach out to our team for custom plans or questions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppColors.brandTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'hello@jobodia.app',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'hello@jobodia.app'),
                    );
                    Navigator.of(sheetContext).pop();
                    Get.snackbar(
                      'Copied',
                      'Email address copied to clipboard.',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandTeal,
                    side: BorderSide(color: AppColors.brandTeal),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Hi Jobodia team, I\'d like to discuss a custom plan.\n\n'
                            'Please contact me at: ',
                        subject: 'Custom Plan Inquiry',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share inquiry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
