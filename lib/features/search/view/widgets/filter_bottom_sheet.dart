import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key, required this.homeController});

  final HomeController homeController;

  static String _formatSalary(double value) {
    final amount = value.round();
    if (amount >= 1000) {
      final thousands = amount / 1000;
      return '\$${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k';
    }
    return '\$$amount';
  }

  static void show(BuildContext context, HomeController homeController) {
    final palette = context.palette;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => FilterBottomSheet(homeController: homeController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter jobs',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: homeController.clearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Experience',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: homeController.levels
                      .map(
                        (level) => FilterChipWidget(
                          label: level,
                          selected: homeController.selectedLevel.value == level,
                          onTap: () => homeController.selectLevel(level),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Location',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: homeController.locations
                      .map(
                        (location) => FilterChipWidget(
                          label: location,
                          selected:
                              homeController.selectedLocation.value == location,
                          onTap: () => homeController.selectLocation(location),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Salary range',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (homeController.hasCustomSalaryRange) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          homeController.updateSalaryRange(
                            homeController.minAvailableSalary.toDouble(),
                            homeController.maxAvailableSalary.toDouble(),
                          );
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${_formatSalary(homeController.minSalaryFilter.value)} – ${_formatSalary(homeController.maxSalaryFilter.value)}',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(
                    homeController.minSalaryFilter.value,
                    homeController.maxSalaryFilter.value,
                  ),
                  min: homeController.minAvailableSalary.toDouble(),
                  max: homeController.maxAvailableSalary.toDouble(),
                  divisions:
                      (homeController.maxAvailableSalary -
                          homeController.minAvailableSalary) ~/
                      100,
                  activeColor: palette.textPrimary,
                  inactiveColor: palette.border,
                  labels: RangeLabels(
                    _formatSalary(homeController.minSalaryFilter.value),
                    _formatSalary(homeController.maxSalaryFilter.value),
                  ),
                  onChanged: (values) => homeController.updateSalaryRange(
                    values.start,
                    values.end,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.textPrimary,
                      foregroundColor: palette.scaffold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Show jobs'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: palette.textPrimary,
      backgroundColor: palette.surfaceMuted,
      labelStyle: TextStyle(
        color: selected ? palette.scaffold : palette.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(
        color: selected ? palette.textPrimary : Colors.transparent,
      ),
    );
  }
}
