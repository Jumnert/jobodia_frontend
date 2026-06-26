import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_search_bar.dart';
import 'package:jobodia_frontend/features/search/controller/search_controller.dart';
import 'package:jobodia_frontend/features/search/view/widgets/filter_bottom_sheet.dart';
import 'package:jobodia_frontend/features/search/view/widgets/search_results_list.dart';

import 'package:jobodia_frontend/features/job_alerts/view/widgets/create_alert_sheet.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static String _formatSalary(double value) {
    final amount = value.round();
    if (amount >= 1000) {
      final thousands = amount / 1000;
      return '\$${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k';
    }
    return '\$$amount';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final searchHistory = Get.isRegistered<JobSearchController>()
        ? Get.find<JobSearchController>()
        : Get.put(JobSearchController());

    return Scaffold(
      backgroundColor: palette.scaffold,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Obx(() {
                        if (homeController.searchQuery.value.isNotEmpty ||
                            homeController.hasActiveFilters) {
                          return IconButton(
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.brandTeal,
                            ),
                            tooltip: 'Save as alert',
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => CreateAlertSheet(
                                  initialKeyword:
                                      homeController.searchQuery.value,
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => HomeSearchBar(
                      value: homeController.searchQuery.value,
                      onChanged: homeController.updateSearchQuery,
                      onSubmitted: (q) {
                        searchHistory.addSearch(q);
                        homeController.updateSearchQuery(q);
                      },
                      onClear: homeController.clearSearch,
                      onFilterPressed: () =>
                          FilterBottomSheet.show(context, homeController),
                      hasActiveFilters: homeController.hasActiveFilters,
                      salaryRangeLabel: homeController.hasCustomSalaryRange
                          ? '${_formatSalary(homeController.minSalaryFilter.value)}–${_formatSalary(homeController.maxSalaryFilter.value)}'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final query = homeController.searchQuery.value;
                final jobs = homeController.filteredJobs;

                if (query.isEmpty && !homeController.hasActiveFilters) {
                  return _buildEmptySearchState(
                    context,
                    palette,
                    homeController,
                    searchHistory,
                  );
                }

                return SearchResultsList(
                  jobs: jobs,
                  query: query,
                  homeController: homeController,
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

  Widget _buildEmptySearchState(
    BuildContext context,
    AppPalette palette,
    HomeController homeController,
    JobSearchController searchHistory,
  ) {
    final trendingTags = homeController.jobs
        .expand((j) => j.tags)
        .toSet()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          Obx(() {
            final recents = searchHistory.recentSearches;
            if (recents.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: searchHistory.clearAll,
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recents.map((query) {
                    return GestureDetector(
                      onTap: () {
                        homeController.updateSearchQuery(query);
                        searchHistory.addSearch(query);
                      },
                      child: Chip(
                        label: Text(
                          query,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        deleteIcon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: palette.iconMuted,
                        ),
                        onDeleted: () => searchHistory.removeSearch(query),
                        backgroundColor: palette.surfaceMuted,
                        side: BorderSide(color: palette.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.only(left: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // Trending Tags
          if (trendingTags.isNotEmpty) ...[
            Text(
              'Trending',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: trendingTags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: palette.surfaceMuted,
                      side: BorderSide(color: palette.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      onPressed: () {
                        searchHistory.addSearch(tag);
                        homeController.updateSearchQuery(tag);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
