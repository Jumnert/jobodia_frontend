import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_search_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Search',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => HomeSearchBar(
                      value: homeController.searchQuery.value,
                      onChanged: homeController.updateSearchQuery,
                      onClear: homeController.clearSearch,
                      onFilterPressed: () =>
                          _showFilterSheet(context, homeController),
                      hasActiveFilters: homeController.hasActiveFilters,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                    child: _SearchJobCard(job: jobs[index], colorIndex: index),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) =>
            navigateMainDestination(context, index, currentIndex: -1),
        onSearchPressed: () {},
      ),
    );
  }

  void _showFilterSheet(BuildContext context, HomeController homeController) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
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
                      const Text(
                        'Filter jobs',
                        style: TextStyle(
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
                  const Text(
                    'Experience',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: homeController.levels
                        .map(
                          (level) => _FilterChip(
                            label: level,
                            selected:
                                homeController.selectedLevel.value == level,
                            onTap: () => homeController.selectLevel(level),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: homeController.locations
                        .map(
                          (location) => _FilterChip(
                            label: location,
                            selected:
                                homeController.selectedLocation.value ==
                                location,
                            onTap: () =>
                                homeController.selectLocation(location),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Salary range',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_formatSalary(homeController.minSalaryFilter.value)} - ${_formatSalary(homeController.maxSalaryFilter.value)}',
                        style: const TextStyle(
                          color: Color(0xFF707070),
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
                    activeColor: Colors.black,
                    inactiveColor: const Color(0xFFE3E3E3),
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
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
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
      ),
    );
  }

  String _formatSalary(double value) {
    final amount = value.round();
    if (amount >= 1000) {
      final thousands = amount / 1000;
      return '\$${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k';
    }
    return '\$$amount';
  }
}

class _SearchJobCard extends StatelessWidget {
  const _SearchJobCard({required this.job, required this.colorIndex});

  final JobFeedModel job;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.to(
          () => const JobDetailScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut<JobDetailController>(JobDetailController.new),
          ),
        ),
        child: JobFeedCard(job: job, colorIndex: colorIndex),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFF3F3F3),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: selected ? Colors.black : Colors.transparent),
    );
  }
}
