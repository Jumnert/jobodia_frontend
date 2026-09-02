import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/config/app_environment.dart';
import 'package:jobodia_frontend/core/widgets/undo_snackbar.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart'
    as jobodia_feature;
import 'package:jobodia_frontend/features/feature_discovery/view/walkthrough_screen.dart'
    as jobodia_feature_view;
import 'package:jobodia_frontend/features/home/data/jobs_api.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

/// The job feed uses bundled, in-memory listings only in the local profile.
/// UAT and production always read listings from the backend.
class HomeController extends GetxController {
  HomeController({JobsApi? jobsApi, GetStorage? storage})
    : _jobsApi = jobsApi ?? JobsApi();

  static const _pageSize = 20;
  static const _localJobs = <JobFeedModel>[
    JobFeedModel(
      id: 'local-product-designer',
      company: 'NovaTech Labs',
      companyTag: 'Verified',
      matchPercent: 98,
      title: 'Product Designer - SaaS',
      level: 'Expert',
      location: 'Phnom Penh',
      timeAgo: '2 hours ago',
      description:
          'Design thoughtful experiences for a growing SaaS product alongside product and engineering teams.',
      tags: ['Figma', 'SaaS Design', 'UX'],
      salary: '\$1,500 - \$2,300',
      distance: '2.4 km away',
    ),
    JobFeedModel(
      id: 'local-frontend-engineer',
      company: 'Mekong Digital',
      companyTag: 'Featured',
      matchPercent: 94,
      title: 'Flutter Developer',
      level: 'Intermediate',
      location: 'Remote',
      timeAgo: '4 hours ago',
      description:
          'Build polished mobile experiences and collaborate with a small product team from planning through release.',
      tags: ['Flutter', 'Dart', 'REST APIs'],
      salary: '\$1,200 - \$2,000',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'local-marketing-specialist',
      company: 'Lotus Commerce',
      companyTag: 'New',
      matchPercent: 90,
      title: 'Digital Marketing Specialist',
      level: 'Mid-level',
      location: 'Phnom Penh',
      timeAgo: '6 hours ago',
      description:
          'Plan campaigns, create useful content, and use performance data to help a local brand grow.',
      tags: ['Social Media', 'Content', 'Analytics'],
      salary: '\$900 - \$1,400',
      distance: '4.1 km away',
    ),
    JobFeedModel(
      id: 'local-data-analyst',
      company: 'InsightWorks',
      companyTag: 'Verified',
      matchPercent: 88,
      title: 'Data Analyst',
      level: 'Intermediate',
      location: 'Phnom Penh',
      timeAgo: '1 day ago',
      description:
          'Turn data into clear dashboards and recommendations that help teams make better decisions.',
      tags: ['SQL', 'Excel', 'Power BI'],
      salary: '\$1,000 - \$1,700',
      distance: '5.8 km away',
    ),
    JobFeedModel(
      id: 'local-customer-success',
      company: 'CloudKamp',
      companyTag: 'Remote',
      matchPercent: 86,
      title: 'Customer Success Associate',
      level: 'Entry level',
      location: 'Remote',
      timeAgo: '1 day ago',
      description:
          'Support customers, solve problems clearly, and help new teams get the most from the product.',
      tags: ['Customer Support', 'Communication', 'SaaS'],
      salary: '\$800 - \$1,200',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'local-operations-coordinator',
      company: 'Angkor Logistics',
      companyTag: 'New',
      matchPercent: 82,
      title: 'Operations Coordinator',
      level: 'Junior',
      location: 'Phnom Penh',
      timeAgo: '2 days ago',
      description:
          'Keep daily operations organized, coordinate partners, and improve dependable delivery processes.',
      tags: ['Operations', 'Coordination', 'Excel'],
      salary: '\$700 - \$1,100',
      distance: '6.3 km away',
    ),
  ];
  final JobsApi _jobsApi;

  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedLevel = RxnString();
  final RxnString selectedLocation = RxnString();
  final RxDouble minSalaryFilter = 0.0.obs;
  final RxDouble maxSalaryFilter = 1000000.0.obs;
  final RxInt jobsRevision = 0.obs;
  final RxSet<String> dismissedJobIds = <String>{}.obs;
  final RxList<JobFeedModel> jobs = <JobFeedModel>[].obs;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentPage = 0.obs;
  final RxBool isLoadingMore = false.obs;
  bool _lastPage = false;

  bool get _usesBundledLocalJobs =>
      AppConfig.environment == AppEnvironment.local;

  bool get hasMoreJobs => !_lastPage;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadJobs(reset: true));
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<jobodia_feature.FeatureDiscoveryController>()) {
      final controller = Get.find<jobodia_feature.FeatureDiscoveryController>();
      if (!controller.hasSeenWalkthrough.value) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          Get.dialog(
            const jobodia_feature_view.WalkthroughScreen(),
            useSafeArea: false,
            barrierDismissible: false,
            barrierColor: const Color(0x00000000),
          );
        });
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> retryLoading() => loadJobs(reset: true);

  Future<void> loadJobs({required bool reset}) async {
    if (isLoading.value || (isLoadingMore.value && !reset)) return;
    if (_usesBundledLocalJobs) {
      hasError.value = false;
      jobs.assignAll(_localJobs);
      currentPage.value = 0;
      _lastPage = true;
      _resetSalaryBounds();
      jobsRevision.value++;
      return;
    }
    if (reset) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    hasError.value = false;
    try {
      final page = reset ? 0 : currentPage.value + 1;
      final result = await _jobsApi.list(page: page, size: _pageSize);
      if (reset) {
        jobs.assignAll(result.jobs);
        currentPage.value = 0;
      } else {
        final existingIds = jobs.map((job) => job.id).toSet();
        jobs.addAll(result.jobs.where((job) => existingIds.add(job.id)));
        currentPage.value = page;
      }
      _lastPage = result.last;
      _resetSalaryBounds();
      jobsRevision.value++;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreJobs || isLoadingMore.value || isLoading.value) return;
    await loadJobs(reset: false);
  }

  void dismiss(JobFeedModel job) {
    dismissedJobIds.add(job.id);
    showUndoSnackbar(
      message: '${job.title} removed from this session',
      onUndo: () => dismissedJobIds.remove(job.id),
    );
  }

  ({List<JobFeedModel> jobs, bool hasMore}) get visiblePage =>
      (jobs: filteredJobs, hasMore: hasMoreJobs);

  void selectTab(int index) => selectedTab.value = index;

  JobFeedModel? jobById(String id) {
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  List<JobFeedModel> get filteredJobs {
    final query = searchQuery.value.trim().toLowerCase();
    final level = selectedLevel.value;
    final location = selectedLocation.value;
    final minSalary = minSalaryFilter.value.round();
    final maxSalary = maxSalaryFilter.value.round();
    final tab = selectedTab.value;
    final savedIds = tab == 2 && Get.isRegistered<SavedJobsController>()
        ? Get.find<SavedJobsController>().savedIds
        : null;

    return jobs
        .where((job) {
          if (dismissedJobIds.contains(job.id)) return false;
          // The backend does not yet provide matching scores. The Best Matches tab
          // shows the live feed rather than inventing a device-only score.
          if (tab == 2 && (savedIds == null || !savedIds.contains(job.id))) {
            return false;
          }
          if (level != null && job.level != level) return false;
          if (location != null && job.location != location) return false;
          final salary = _parseSalaryRange(job.salary);
          if (salary.$2 < minSalary || salary.$1 > maxSalary) return false;
          if (query.isEmpty) return true;
          return [
            job.company,
            job.companyTag,
            job.title,
            job.level,
            job.location,
            job.description,
            job.salary,
            job.distance,
            ...job.tags,
          ].join(' ').toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  List<String> get levels => jobs.map((job) => job.level).toSet().toList();
  List<String> get locations =>
      jobs.map((job) => job.location).toSet().toList();

  int get minAvailableSalary {
    if (jobs.isEmpty) return 0;
    return jobs
        .map((job) => _parseSalaryRange(job.salary).$1)
        .reduce((a, b) => a < b ? a : b);
  }

  int get maxAvailableSalary {
    if (jobs.isEmpty) return 1000000;
    return jobs
        .map((job) => _parseSalaryRange(job.salary).$2)
        .reduce((a, b) => a > b ? a : b);
  }

  bool get hasCustomSalaryRange =>
      minSalaryFilter.value.round() != minAvailableSalary ||
      maxSalaryFilter.value.round() != maxAvailableSalary;

  bool get hasActiveFilters =>
      selectedLevel.value != null ||
      selectedLocation.value != null ||
      hasCustomSalaryRange;

  void selectLevel(String? value) =>
      selectedLevel.value = selectedLevel.value == value ? null : value;

  void selectLocation(String? value) =>
      selectedLocation.value = selectedLocation.value == value ? null : value;

  void updateSalaryRange(double start, double end) {
    minSalaryFilter.value = start;
    maxSalaryFilter.value = end;
  }

  void clearFilters() {
    selectedLevel.value = null;
    selectedLocation.value = null;
    _resetSalaryBounds();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;
  void clearSearch() => searchQuery.value = '';

  void _resetSalaryBounds() {
    minSalaryFilter.value = minAvailableSalary.toDouble();
    maxSalaryFilter.value = maxAvailableSalary.toDouble();
  }

  (int, int) _parseSalaryRange(String salary) {
    final amounts = RegExp(r'[\d,]+')
        .allMatches(salary)
        .map((match) {
          return int.tryParse(match.group(0)!.replaceAll(',', '')) ?? 0;
        })
        .toList(growable: false);
    if (amounts.isEmpty) return (0, 0);
    return amounts.length == 1
        ? (amounts.first, amounts.first)
        : (amounts.first, amounts[1]);
  }
}
