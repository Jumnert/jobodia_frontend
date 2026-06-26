import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/salary/controller/salary_controller.dart';
import 'package:jobodia_frontend/features/salary/view/widgets/salary_chart_painter.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(SalaryController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Market Value',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandTeal),
          );
        }

        final insight = ctrl.insight.value;
        if (insight == null) {
          return Center(
            child: Text(
              'Failed to load salary insights',
              style: TextStyle(color: palette.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salary Insights',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your profile, experience, and the current market demand for ${insight.role}.',
                style: TextStyle(color: palette.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Key Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Median Salary',
                      value:
                          '\$${(insight.medianSalary / 1000).toStringAsFixed(0)}k',
                      palette: palette,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Market Demand',
                      value: insight.demandLevel.name.capitalizeFirst!,
                      palette: palette,
                      valueColor: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Chart Area
              Text(
                'Salary Distribution',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                ),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: SalaryChartPainter(
                      minSalary: insight.minSalary,
                      maxSalary: insight.maxSalary,
                      medianSalary: insight.medianSalary,
                      expectedSalary: insight.userExpectedSalary,
                      textColor: palette.textPrimary,
                      mutedColor: palette.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.brandTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Negotiation Tip',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your expected salary is below the market median. Consider asking for \$${(insight.medianSalary / 1000).toStringAsFixed(0)}k to match market standards.',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.palette,
    this.valueColor,
  });

  final String title;
  final String value;
  final AppPalette palette;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
