import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

enum _BillingCycle { monthly, yearly }

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  _BillingCycle _billingCycle = _BillingCycle.monthly;
  int _selectedPlanIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plans = _plans(yearly: _billingCycle == _BillingCycle.yearly);
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
            _PlanTabs(
              plans: plans,
              selectedIndex: _selectedPlanIndex,
              onChanged: (index) => setState(() => _selectedPlanIndex = index),
            ),
            const SizedBox(height: 16),
            _SelectedPlanCard(
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
            const _FaqCard(),
          ],
        ),
      ),
    );
  }

  List<_Plan> _plans({required bool yearly}) {
    return [
      _Plan(
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
      _Plan(
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
      _Plan(
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

class _PlanTabs extends StatelessWidget {
  const _PlanTabs({
    required this.plans,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_Plan> plans;
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

class _SelectedPlanCard extends StatelessWidget {
  const _SelectedPlanCard({
    required this.plan,
    required this.billingCycle,
    required this.onBillingChanged,
  });

  final _Plan plan;
  final _BillingCycle billingCycle;
  final ValueChanged<_BillingCycle?> onBillingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26292C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(plan.icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                plan.delivery,
                style: const TextStyle(
                  color: Color(0xFFC5C8CB),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: const TextStyle(
              color: Color(0xFF9EA4A9),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                r'$',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                plan.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  '/${plan.period}',
                  style: const TextStyle(
                    color: Color(0xFFC5C8CB),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CupertinoSlidingSegmentedControl<_BillingCycle>(
            groupValue: billingCycle,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: Colors.white,
            children: {
              _BillingCycle.monthly: _BillingChip(
                label: 'Monthly',
                selected: billingCycle == _BillingCycle.monthly,
              ),
              _BillingCycle.yearly: _BillingChip(
                label: 'Yearly',
                selected: billingCycle == _BillingCycle.yearly,
              ),
            },
            onValueChanged: onBillingChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: () => Get.snackbar(
                  'Pricing',
                  '${plan.name} checkout will be connected here.',
                  snackPosition: SnackPosition.BOTTOM,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Get started'),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillingChip extends StatelessWidget {
  const _BillingChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BenefitPanel extends StatelessWidget {
  const _BenefitPanel({required this.plan});

  final _Plan plan;

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
              TextButton(onPressed: () {}, child: const Text('Contact us')),
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

class _FaqCard extends StatelessWidget {
  const _FaqCard();

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
          color: dark ? Colors.white : Colors.white,
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

class _Plan {
  const _Plan({
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
