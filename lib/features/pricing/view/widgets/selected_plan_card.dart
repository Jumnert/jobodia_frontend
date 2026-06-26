import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/pricing/controller/pricing_controller.dart';
import '../pricing_screen.dart'; // For PricingPlan

enum BillingCycle { monthly, yearly }

class SelectedPlanCard extends StatelessWidget {
  const SelectedPlanCard({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.onBillingChanged,
  });

  final PricingPlan plan;
  final BillingCycle billingCycle;
  final ValueChanged<BillingCycle?> onBillingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? context.palette.surface : Colors.black,
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
              if (Get.isRegistered<PricingController>() &&
                  Get.find<PricingController>().isCurrentPlan(plan.name))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00856F).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Current plan',
                    style: TextStyle(
                      color: Color(0xFF00D4AA),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
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
          CupertinoSlidingSegmentedControl<BillingCycle>(
            groupValue: billingCycle,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: Colors.white,
            children: {
              BillingCycle.monthly: _BillingChip(
                label: 'Monthly',
                selected: billingCycle == BillingCycle.monthly,
              ),
              BillingCycle.yearly: _BillingChip(
                label: 'Yearly',
                selected: billingCycle == BillingCycle.yearly,
              ),
            },
            onValueChanged: onBillingChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: () {
                  unawaited(HapticFeedback.mediumImpact());
                  final pricingCtrl = Get.find<PricingController>();
                  final cycleLabel = billingCycle == BillingCycle.yearly
                      ? 'yearly'
                      : 'monthly';

                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.palette.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(plan.icon, size: 40, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text(
                            '${plan.name} Plan',
                            style: TextStyle(
                              color: context.palette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${plan.price}/${plan.period}',
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pricingCtrl.isCurrentPlan(plan.name)
                                ? 'You\'re already on the ${plan.name} plan!'
                                : 'Confirm switching to the ${plan.name} plan?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.palette.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                pricingCtrl.selectPlan(plan.name, cycleLabel);
                                Get.back();
                                Get.snackbar(
                                  'Plan updated',
                                  'You\'re now on the ${plan.name} plan.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                pricingCtrl.isCurrentPlan(plan.name)
                                    ? 'Got it'
                                    : 'Confirm',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                child: Text(plan.cta),
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
