import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/interview/controller/mock_interview_controller.dart';
import 'package:jobodia_frontend/features/interview/data/mock_interview_questions.dart';

/// Total seconds per question for the mock-interview timer.
const _timerDuration = 90;

/// Mock Interview screen with timer, self-rating, and session history.
class MockInterviewScreen extends GetView<MockInterviewController> {
  const MockInterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  tooltip: 'Back',
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: palette.iconPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Mock Interview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isFinished.value) {
                  return _SummaryView(controller: controller);
                }
                return _QuestionView(
                  controller: controller,
                  question:
                      mockInterviewQuestions[controller.currentIndex.value],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.controller});

  final MockInterviewController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Obx(() {
      final secs = controller.timerSeconds.value;
      final progress = secs / _timerDuration;
      Color progressColor;
      if (secs > 30) {
        progressColor = palette.success;
      } else if (secs > 10) {
        progressColor = palette.warning;
      } else {
        progressColor = palette.error;
      }

      final minutes = secs ~/ 60;
      final seconds = secs % 60;
      final timeLabel = '$minutes:${seconds.toString().padLeft(2, '0')}';

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: progressColor),
                const SizedBox(width: 6),
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: controller.pauseResume,
                  icon: Icon(
                    controller.isTimerPaused.value
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 22,
                    color: palette.iconMuted,
                  ),
                  tooltip: controller.isTimerPaused.value
                      ? 'Resume timer'
                      : 'Pause timer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: palette.border,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.controller, required this.question});

  final MockInterviewController controller;
  final InterviewQuestion question;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        // Question progress
        Obx(() {
          final index = controller.currentIndex.value;
          final total = controller.totalQuestions;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 6,
                    backgroundColor: palette.border,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${index + 1} of $total',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
        // Timer bar
        _TimerBar(controller: controller),
        // Question + answer + rating
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                ),
                child: Text(
                  question.prompt,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 19,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() {
                final revealed = controller.isAnswerRevealed.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (revealed)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF7C3AED,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MODEL ANSWER',
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.modelAnswer,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (!revealed)
                      TextButton.icon(
                        onPressed: controller.revealAnswer,
                        icon: const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                        ),
                        label: const Text('Reveal answer'),
                      ),
                    if (revealed) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Rate your answer:',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Nailed it'),
                            selected: controller.lastRating.value == 'nailed',
                            selectedColor: palette.success.withValues(
                              alpha: 0.2,
                            ),
                            backgroundColor: palette.surface,
                            side: BorderSide(
                              color: controller.lastRating.value == 'nailed'
                                  ? palette.success
                                  : palette.border,
                            ),
                            labelStyle: TextStyle(
                              color: controller.lastRating.value == 'nailed'
                                  ? palette.success
                                  : palette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            onSelected: (_) => controller.rate('nailed'),
                          ),
                          ChoiceChip(
                            label: const Text('Almost'),
                            selected: controller.lastRating.value == 'almost',
                            selectedColor: palette.warning.withValues(
                              alpha: 0.2,
                            ),
                            backgroundColor: palette.surface,
                            side: BorderSide(
                              color: controller.lastRating.value == 'almost'
                                  ? palette.warning
                                  : palette.border,
                            ),
                            labelStyle: TextStyle(
                              color: controller.lastRating.value == 'almost'
                                  ? palette.warning
                                  : palette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            onSelected: (_) => controller.rate('almost'),
                          ),
                          ChoiceChip(
                            label: const Text('Missed it'),
                            selected: controller.lastRating.value == 'missed',
                            selectedColor: palette.error.withValues(alpha: 0.2),
                            backgroundColor: palette.surface,
                            side: BorderSide(
                              color: controller.lastRating.value == 'missed'
                                  ? palette.error
                                  : palette.border,
                            ),
                            labelStyle: TextStyle(
                              color: controller.lastRating.value == 'missed'
                                  ? palette.error
                                  : palette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            onSelected: (_) => controller.rate('missed'),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
        // Navigation buttons
        Obx(() {
          final index = controller.currentIndex.value;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                if (index > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textPrimary,
                        side: BorderSide(color: palette.border),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: controller.nextQuestion,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      index + 1 == controller.totalQuestions
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.controller});

  final MockInterviewController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF7C3AED),
              size: 46,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${controller.scorePercent}%',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interview complete',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BreakdownChip(
                label: 'Nailed',
                count: controller.nailedCount,
                color: palette.success,
              ),
              const SizedBox(width: 10),
              _BreakdownChip(
                label: 'Almost',
                count: controller.almostCount,
                color: palette.warning,
              ),
              const SizedBox(width: 10),
              _BreakdownChip(
                label: 'Missed',
                count: controller.missedCount,
                color: palette.error,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.totalQuestions} questions',
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.resetSession,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: Get.back,
              style: TextButton.styleFrom(foregroundColor: palette.textPrimary),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
