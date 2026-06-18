import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/interview/view/flashcards_screen.dart';
import 'package:jobodia_frontend/features/interview/view/mock_interview_screen.dart';
import 'package:jobodia_frontend/features/interview/view/recruiter_messages_screen.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';

/// Interview preparation hub. List-style layout (mirrors Settings) with three
/// modules: Mock Interview, Flash Cards, and recruiter message templates.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101214)
        : const Color(0xFFF5F6F8);
    final foregroundColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark
        ? const Color(0xFFA5ABB1)
        : const Color(0xFF6F7378);
    final cardColor = isDark ? const Color(0xFF1A1D20) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2A2E33)
        : const Color(0xFFEDEDED);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 112),
          children: [
            Text(
              'Interview Prep',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Rehearse, study, and reach out with confidence before the real '
              'thing.',
              style: TextStyle(color: mutedColor, fontSize: 14, height: 1.3),
            ),
            const SizedBox(height: 22),
            _ModuleCard(
              icon: Icons.record_voice_over_rounded,
              title: 'Mock Interview',
              subtitle: 'Step through a simulated technical interview.',
              cardColor: cardColor,
              borderColor: borderColor,
              foregroundColor: foregroundColor,
              mutedColor: mutedColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MockInterviewScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.style_rounded,
              title: 'Flash Cards',
              subtitle: 'Study HTML, CSS, and JavaScript concepts.',
              cardColor: cardColor,
              borderColor: borderColor,
              foregroundColor: foregroundColor,
              mutedColor: mutedColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FlashcardsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.forum_rounded,
              title: 'How to Chat to Recruiter?',
              subtitle: 'Ready-to-send professional message templates.',
              cardColor: cardColor,
              borderColor: borderColor,
              foregroundColor: foregroundColor,
              mutedColor: mutedColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RecruiterMessagesScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (showBottomNav ?? true)
          ? AppBottomNavigationBar(
              selectedIndex: 3,
              onDestinationSelected: (index) =>
                  navigateMainDestination(context, index, currentIndex: 3),
              onSearchPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
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
    required this.cardColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.mutedColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
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
                      color: foregroundColor,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: mutedColor, size: 22),
          ],
        ),
      ),
    );
  }
}
