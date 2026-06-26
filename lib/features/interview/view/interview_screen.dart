import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/interview/controller/interview_schedule_controller.dart';
import 'package:jobodia_frontend/features/interview/controller/mock_interview_controller.dart';
import 'package:jobodia_frontend/features/interview/view/flashcards_screen.dart';
import 'package:jobodia_frontend/features/interview/view/mock_interview_screen.dart';
import 'package:jobodia_frontend/features/interview/view/recruiter_messages_screen.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Interview preparation hub. List-style layout (mirrors Settings) with three
/// modules: Mock Interview, Flash Cards, and recruiter message templates.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 112),
          children: [
            Text(
              'Interview Prep',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Rehearse, study, and reach out with confidence before the real '
              'thing.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 22),
            // ── Upcoming Interviews ──
            if (Get.isRegistered<InterviewScheduleController>())
              Obx(() {
                final scheduleCtrl = Get.find<InterviewScheduleController>();
                if (scheduleCtrl.schedules.isEmpty) {
                  return const SizedBox.shrink();
                }
                final homeCtrl = Get.isRegistered<HomeController>()
                    ? Get.find<HomeController>()
                    : Get.put(HomeController());
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Upcoming Interviews',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...scheduleCtrl.schedules.map((s) {
                        final job = homeCtrl.jobById(s.jobId);
                        final title = job?.title ?? s.jobId;
                        final date = s.dateTime;
                        final formattedDate =
                            '${_months[date.month - 1]} ${date.day}, ${date.year}';
                        final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
                        final minute = date.minute.toString().padLeft(2, '0');
                        final amPm = date.hour >= 12 ? 'PM' : 'AM';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$formattedDate at $hour:$minute $amPm',
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => scheduleCtrl.remove(s.jobId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD93B3B,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Color(0xFFD93B3B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            // ── Empty activity state ──
            Obx(() {
              final noSchedules =
                  !Get.isRegistered<InterviewScheduleController>() ||
                  Get.find<InterviewScheduleController>().schedules.isEmpty;
              final noSessions =
                  !Get.isRegistered<MockInterviewController>() ||
                  Get.find<MockInterviewController>().pastSessions.isEmpty;
              if (!noSchedules || !noSessions) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 40,
                        color: palette.iconMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No interview activity yet',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule interviews or try a mock session to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            _ModuleCard(
              icon: Icons.record_voice_over_rounded,
              title: 'Mock Interview',
              subtitle: 'Step through a simulated technical interview.',
              onTap: () => Get.to(
                () => const MockInterviewScreen(),
                binding: BindingsBuilder(
                  () => Get.lazyPut<MockInterviewController>(
                    MockInterviewController.new,
                  ),
                ),
              ),
            ),
            if (Get.isRegistered<MockInterviewController>())
              Obx(() {
                final ctrl = Get.find<MockInterviewController>();
                if (ctrl.pastSessions.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Past Sessions',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...ctrl.pastSessions.take(5).map((s) {
                          final date = DateTime.parse(s['date'] as String);
                          final formatted =
                              '${_months[date.month - 1]} ${date.day}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 16,
                                  color: palette.iconMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$formatted  — ${s['score']}%',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.style_rounded,
              title: 'Flash Cards',
              subtitle: 'Study HTML, CSS, and JavaScript concepts.',
              onTap: () => Get.to<void>(() => const FlashcardsScreen()),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.forum_rounded,
              title: 'How to Chat to Recruiter?',
              subtitle: 'Ready-to-send professional message templates.',
              onTap: () => Get.toNamed<void>(AppRoutes.conversations),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (showBottomNav ?? true)
          ? AppBottomNavigationBar(
              selectedIndex: 3,
              onDestinationSelected: (index) =>
                  navigateMainDestination(context, index, currentIndex: 3),
              onSearchPressed: () => Get.toNamed<void>(AppRoutes.search),
            )
          : null,
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
