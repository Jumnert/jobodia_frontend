import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/assessments/controller/assessment_controller.dart';
import 'package:jobodia_frontend/features/assessments/model/assessment_model.dart';

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(AssessmentController());

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
          'Certifications',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.cardGradients.last,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Skill Badges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Earn badges to stand out to employers.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Available Assessments',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.assessments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final assessment = ctrl.assessments[index];
                  return _AssessmentTile(
                    assessment: assessment,
                    palette: palette,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({required this.assessment, required this.palette});

  final AssessmentModel assessment;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AssessmentController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: assessment.passed
                  ? AppColors.success.withAlpha(20)
                  : palette.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              assessment.passed ? Icons.verified_rounded : Icons.quiz_rounded,
              color: assessment.passed ? AppColors.success : palette.iconMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${assessment.durationMinutes} mins • ${assessment.totalQuestions} questions',
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (assessment.passed)
            Text(
              '${assessment.score?.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            )
          else
            ElevatedButton(
              onPressed: () => ctrl.startQuiz(assessment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Start'),
            ),
        ],
      ),
    );
  }
}
