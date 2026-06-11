import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_tab_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_top_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/notifications/view/notifications_screen.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';
import 'package:jobodia_frontend/features/settings/view/settings_screen.dart';

/// Home feed screen shown after login succeeds.
class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeTopBar(
                    name: 'Jumnert',
                    avatarUrl: user?.avatarUrl,
                    onNotifications: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 0,
                    height: 0,
                    child: Column(
                      children: [
                        Text('Welcome, Test User'),
                        Text('test@gmail.com'),
                        Text('Candidate'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Jobs you might like',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => HomeTabBar(
                      selectedIndex: homeController.selectedTab.value,
                      onChanged: homeController.selectTab,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final jobs = homeController.filteredJobs;

                if (jobs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(32, 0, 32, 24),
                      child: Text(
                        'No jobs match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _JobFeedContextMenu(job: jobs[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (showBottomNav ?? true)
          ? AppBottomNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) =>
                  navigateMainDestination(context, index, currentIndex: 0),
              onSearchPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
            )
          : null,
    );
  }
}

class _JobFeedContextMenu extends StatelessWidget {
  const _JobFeedContextMenu({required this.job});

  final JobFeedModel job;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CupertinoContextMenu(
          actions: [
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.flag,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Report'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.heart,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fave'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.share,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Share'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.hand_thumbsdown,
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not interested'),
            ),
          ],
          child: SizedBox(
            width: constraints.maxWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.to(
                () => const JobDetailScreen(),
                binding: BindingsBuilder(
                  () =>
                      Get.lazyPut<JobDetailController>(JobDetailController.new),
                ),
              ),
              child: JobFeedCard(job: job),
            ),
          ),
        );
      },
    );
  }
}
