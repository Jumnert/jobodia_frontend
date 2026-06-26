import 'package:flutter/material.dart';

/// A pricing plan shown on the pricing screen.
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
