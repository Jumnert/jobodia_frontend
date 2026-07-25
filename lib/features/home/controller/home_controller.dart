import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/widgets/undo_snackbar.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart'
    as jobodia_feature;
import 'package:jobodia_frontend/features/feature_discovery/view/walkthrough_screen.dart'
    as jobodia_feature_view;
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

class HomeController extends GetxController {
  HomeController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _dismissedKey = 'dismissedJobIds';
  static const _selectedTabKey = 'homeSelectedTab';

  final GetStorage _storage;

  final RxInt selectedTab = 1.obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedLevel = RxnString();
  final RxnString selectedLocation = RxnString();
  final RxDouble minSalaryFilter = 2800.0.obs;
  final RxDouble maxSalaryFilter = 7200.0.obs;

  final RxSet<String> dismissedJobIds = <String>{}.obs;

  final ScrollController scrollController = ScrollController();

  /// True while initial data is loading.
  final RxBool isLoading = false.obs;

  /// True if loading fails.
  final RxBool hasError = false.obs;

  void retryLoading() {
    hasError.value = false;
    isLoading.value = true;
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      isLoading.value = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    final storedDismissed = _storage.read<List>(_dismissedKey);
    if (storedDismissed != null) {
      dismissedJobIds.addAll(storedDismissed.cast<String>());
    }
    final storedTab = _storage.read<int>(_selectedTabKey);
    if (storedTab != null) {
      selectedTab.value = storedTab;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<jobodia_feature.FeatureDiscoveryController>()) {
      final fdCtrl = Get.find<jobodia_feature.FeatureDiscoveryController>();
      if (!fdCtrl.hasSeenWalkthrough.value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.dialog(
            const jobodia_feature_view.WalkthroughScreen(),
            useSafeArea: false,
            barrierDismissible: false,
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

  void dismiss(JobFeedModel job) {
    dismissedJobIds.add(job.id);
    _storage.write(_dismissedKey, dismissedJobIds.toList());

    showUndoSnackbar(
      message: '${job.title} removed from feed',
      onUndo: () {
        dismissedJobIds.remove(job.id);
        _storage.write(_dismissedKey, dismissedJobIds.toList());
      },
    );
  }

  // --- Pagination state ---
  static const _pageSize = 5;
  final RxInt currentPage = 1.obs;
  final RxBool isLoadingMore = false.obs;
  bool get hasMoreJobs => currentPage.value * _pageSize < filteredJobs.length;

  void loadMore() {
    if (!hasMoreJobs || isLoadingMore.value) return;
    isLoadingMore.value = true;
    // Simulate network delay.
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      currentPage.value++;
      isLoadingMore.value = false;
    });
  }

  /// Jobs to display given the current page.
  List<JobFeedModel> get pagedJobs {
    final all = filteredJobs;
    final end = (currentPage.value * _pageSize).clamp(0, all.length);
    return all.sublist(0, end);
  }

  /// Combined paged jobs + hasMore in a single pass, so the feed screen runs
  /// the (regex-based) filtering exactly once per frame instead of three times.
  ({List<JobFeedModel> jobs, bool hasMore}) get visiblePage {
    final all = filteredJobs;
    final end = (currentPage.value * _pageSize).clamp(0, all.length);
    return (jobs: all.sublist(0, end), hasMore: end < all.length);
  }

  void _resetPagination() => currentPage.value = 1;

  final jobs = const <JobFeedModel>[
    JobFeedModel(
      id: 'novatech-product-designer',
      company: 'NovaTech Labs',
      companyTag: 'Verified',
      matchPercent: 98,
      title: 'Product Designer - SaaS',
      level: 'Expert',
      location: 'Singapore',
      timeAgo: '2 hours ago',
      description:
          'Design intuitive user experiences for SaaS products, from wireframes to high-fidelity UI. Work closely with product and engineering teams to ship polished interfaces.',
      tags: ['Figma', 'SaaS Design', 'Web Design', 'Mockup'],
      salary: '\$3,500 - \$5,200',
      distance: '3.5 km away',
    ),
    JobFeedModel(
      id: 'finverse-ui-designer',
      company: 'Finverse',
      companyTag: 'Featured',
      matchPercent: 92,
      title: 'UI Designer - Fintech App',
      level: 'Intermediate',
      location: 'Singapore',
      timeAgo: '2 hours ago',
      description:
          'Design intuitive user experiences for fintech applications, from wireframes to high-fidelity UI. Work closely with product and engineering teams to ship polished interfaces.',
      tags: ['UI Design', 'Mobile UI', 'Finance', 'Branding'],
      salary: '\$2,800 - \$4,300',
      distance: '1.2 km away',
    ),
    JobFeedModel(
      id: 'govtech-ux-researcher',
      company: 'GovTech USA',
      companyTag: 'Government',
      matchPercent: 88,
      title: 'UX Researcher',
      level: 'Senior',
      location: 'Washington, DC',
      timeAgo: '5 hours ago',
      description:
          'Shape digital services used by citizens. Collaborate with policy teams, designers, and engineers to improve core government workflows.',
      tags: ['Research', 'Service Design', 'Accessibility'],
      salary: '\$5,100 - \$7,200',
      distance: '8.7 km away',
    ),
    JobFeedModel(
      id: 'metro-frontend-engineer',
      company: 'Metro Digital',
      companyTag: 'Remote',
      matchPercent: 84,
      title: 'Frontend Engineer',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '8 hours ago',
      description:
          'Build responsive job marketplace features, refine interactions, and keep the UI fast and dependable across devices.',
      tags: ['Flutter', 'React', 'UI Systems'],
      salary: '\$4,200 - \$6,000',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'synthwave-data-analyst',
      company: 'Synthwave Analytics',
      companyTag: 'Featured',
      matchPercent: 91,
      title: 'Data Analyst',
      level: 'Intermediate',
      location: 'Singapore',
      timeAgo: '1 day ago',
      description:
          'Analyze datasets and build dashboards that inform business decisions. Collaborate with product and engineering to define KPIs.',
      tags: ['SQL', 'Python', 'Tableau', 'Analytics'],
      salary: '\$3,800 - \$5,500',
      distance: '2.1 km away',
    ),
    JobFeedModel(
      id: 'helix-mobile-dev',
      company: 'Helix Apps',
      companyTag: 'Startup',
      matchPercent: 87,
      title: 'Mobile Developer',
      level: 'Senior',
      location: 'Remote',
      timeAgo: '1 day ago',
      description:
          'Build cross-platform mobile apps with Flutter. Own features end-to-end from architecture to release.',
      tags: ['Flutter', 'Dart', 'Firebase', 'CI/CD'],
      salary: '\$5,000 - \$7,500',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'pinnacle-product-mgr',
      company: 'Pinnacle Corp',
      companyTag: 'Verified',
      matchPercent: 79,
      title: 'Product Manager',
      level: 'Expert',
      location: 'Washington, DC',
      timeAgo: '2 days ago',
      description:
          'Lead cross-functional teams to ship enterprise software products. Define roadmaps, prioritize features, and drive adoption.',
      tags: ['Product Strategy', 'Agile', 'Stakeholder Mgmt'],
      salary: '\$6,500 - \$9,000',
      distance: '5.3 km away',
    ),
    JobFeedModel(
      id: 'atlas-devops-eng',
      company: 'Atlas Cloud',
      companyTag: 'Remote',
      matchPercent: 82,
      title: 'DevOps Engineer',
      level: 'Senior',
      location: 'Remote',
      timeAgo: '2 days ago',
      description:
          'Manage cloud infrastructure, CI/CD pipelines, and monitoring. Automate deployments and improve reliability.',
      tags: ['AWS', 'Docker', 'Kubernetes', 'Terraform'],
      salary: '\$5,500 - \$8,000',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'nova-ux-writer',
      company: 'NovaTech Labs',
      companyTag: 'Verified',
      matchPercent: 76,
      title: 'UX Writer',
      level: 'Intermediate',
      location: 'Singapore',
      timeAgo: '3 days ago',
      description:
          'Craft clear, concise microcopy for web and mobile interfaces. Collaborate with design and content teams.',
      tags: ['UX Writing', 'Content Design', 'Figma'],
      salary: '\$3,200 - \$4,800',
      distance: '3.5 km away',
    ),
    JobFeedModel(
      id: 'zenith-backend-dev',
      company: 'Zenith Systems',
      companyTag: 'Government',
      matchPercent: 85,
      title: 'Backend Developer',
      level: 'Mid-level',
      location: 'Washington, DC',
      timeAgo: '4 days ago',
      description:
          'Design and implement REST APIs and microservices. Work with PostgreSQL, Redis, and message queues.',
      tags: ['Node.js', 'PostgreSQL', 'REST', 'Redis'],
      salary: '\$4,500 - \$6,500',
      distance: '6.8 km away',
    ),
    JobFeedModel(
      id: 'orion-qa-engineer',
      company: 'Orion QA Labs',
      companyTag: 'Startup',
      matchPercent: 73,
      title: 'QA Engineer',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '5 days ago',
      description:
          'Write automated tests, maintain test suites, and ensure quality across web and mobile platforms.',
      tags: ['Testing', 'Selenium', 'Appium', 'CI/CD'],
      salary: '\$3,600 - \$5,200',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'lumina-data-scientist',
      company: 'Lumina Data',
      companyTag: 'Enterprise',
      matchPercent: 88,
      title: 'Data Scientist',
      level: 'Senior',
      location: 'New York, NY',
      timeAgo: '1 day ago',
      description:
          'Apply machine learning techniques to solve complex business problems. Build predictive models and dashboards.',
      tags: ['Python', 'Machine Learning', 'SQL', 'Tableau'],
      salary: '\$6,000 - \$8,500',
      distance: '2.1 km away',
    ),
    JobFeedModel(
      id: 'vertex-mobile-dev',
      company: 'Vertex Mobile',
      companyTag: 'Startup',
      matchPercent: 91,
      title: 'Flutter Developer',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '6 hours ago',
      description:
          'Create high-performance, beautiful mobile apps using Flutter. Work closely with product designers and backend teams.',
      tags: ['Flutter', 'Dart', 'Firebase', 'Mobile'],
      salary: '\$4,000 - \$5,500',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'aegis-security-eng',
      company: 'Aegis Security',
      companyTag: 'Agency',
      matchPercent: 77,
      title: 'Security Engineer',
      level: 'Senior',
      location: 'Austin, TX',
      timeAgo: '3 days ago',
      description:
          'Conduct penetration testing and secure code reviews. Monitor systems for vulnerabilities and respond to incidents.',
      tags: ['Cybersecurity', 'Python', 'AWS', 'Pen Testing'],
      salary: '\$5,500 - \$7,800',
      distance: '4.5 km away',
    ),
    JobFeedModel(
      id: 'harbor-fullstack-engineer',
      company: 'Harbor Works',
      companyTag: 'Remote',
      matchPercent: 86,
      title: 'Full Stack Engineer',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '3 hours ago',
      description:
          'Build customer-facing tools and reliable APIs for a growing logistics platform.',
      tags: ['TypeScript', 'React', 'Node.js', 'PostgreSQL'],
      salary: '\$4,800 - \$6,800',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'bloom-growth-marketer',
      company: 'Bloom Commerce',
      companyTag: 'Featured',
      matchPercent: 81,
      title: 'Growth Marketing Specialist',
      level: 'Intermediate',
      location: 'Singapore',
      timeAgo: '5 hours ago',
      description:
          'Plan experiments across lifecycle, paid acquisition, and conversion funnels.',
      tags: ['Growth', 'Analytics', 'SEO', 'Campaigns'],
      salary: '\$3,400 - \$4,900',
      distance: '4.1 km away',
    ),
    JobFeedModel(
      id: 'circuit-android-engineer',
      company: 'Circuit Health',
      companyTag: 'Startup',
      matchPercent: 89,
      title: 'Android Engineer',
      level: 'Senior',
      location: 'Bangkok, Thailand',
      timeAgo: '7 hours ago',
      description:
          'Ship accessible mobile experiences for clinicians and patients.',
      tags: ['Kotlin', 'Compose', 'Android', 'Testing'],
      salary: '\$4,100 - \$6,300',
      distance: '12.4 km away',
    ),
    JobFeedModel(
      id: 'evergreen-hr-partner',
      company: 'Evergreen People',
      companyTag: 'Verified',
      matchPercent: 72,
      title: 'People Operations Partner',
      level: 'Mid-level',
      location: 'Singapore',
      timeAgo: '9 hours ago',
      description:
          'Support hiring, onboarding, and employee programs for distributed teams.',
      tags: ['HR', 'Recruiting', 'Onboarding', 'People Ops'],
      salary: '\$3,600 - \$5,000',
      distance: '2.8 km away',
    ),
    JobFeedModel(
      id: 'forge-product-analyst',
      company: 'Forge Metrics',
      companyTag: 'Enterprise',
      matchPercent: 90,
      title: 'Product Analyst',
      level: 'Senior',
      location: 'Remote',
      timeAgo: '11 hours ago',
      description:
          'Turn product data into clear recommendations for teams building B2B software.',
      tags: ['SQL', 'Amplitude', 'Python', 'Product'],
      salary: '\$5,200 - \$7,100',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'glow-motion-designer',
      company: 'Glow Studio',
      companyTag: 'Agency',
      matchPercent: 78,
      title: 'Motion Designer',
      level: 'Intermediate',
      location: 'Phnom Penh, Cambodia',
      timeAgo: '12 hours ago',
      description:
          'Create expressive product motion, social video, and launch assets for digital brands.',
      tags: ['After Effects', 'Figma', 'Animation', 'Video'],
      salary: '\$1,800 - \$3,000',
      distance: '6.2 km away',
    ),
    JobFeedModel(
      id: 'northstar-cloud-architect',
      company: 'Northstar Cloud',
      companyTag: 'Verified',
      matchPercent: 84,
      title: 'Cloud Solutions Architect',
      level: 'Expert',
      location: 'New York, NY',
      timeAgo: '14 hours ago',
      description:
          'Guide enterprise customers through scalable cloud migrations and platform design.',
      tags: ['AWS', 'Architecture', 'Terraform', 'Security'],
      salary: '\$6,800 - \$7,200',
      distance: '3.6 km away',
    ),
    JobFeedModel(
      id: 'orbit-customer-success',
      company: 'Orbit CRM',
      companyTag: 'Remote',
      matchPercent: 75,
      title: 'Customer Success Manager',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '16 hours ago',
      description:
          'Help customers adopt a workflow platform and grow long-term product value.',
      tags: ['Customer Success', 'SaaS', 'Onboarding', 'CRM'],
      salary: '\$3,900 - \$5,800',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'pebble-ios-engineer',
      company: 'Pebble Finance',
      companyTag: 'Featured',
      matchPercent: 93,
      title: 'iOS Engineer',
      level: 'Senior',
      location: 'Singapore',
      timeAgo: '18 hours ago',
      description:
          'Build polished, secure banking experiences for a mobile-first finance product.',
      tags: ['Swift', 'SwiftUI', 'iOS', 'Fintech'],
      salary: '\$5,800 - \$8,000',
      distance: '1.7 km away',
    ),
    JobFeedModel(
      id: 'quanta-machine-learning',
      company: 'Quanta AI',
      companyTag: 'Startup',
      matchPercent: 88,
      title: 'Machine Learning Engineer',
      level: 'Senior',
      location: 'Remote',
      timeAgo: '1 day ago',
      description:
          'Productionize ranking and recommendation models for a global learning product.',
      tags: ['Python', 'PyTorch', 'MLOps', 'AWS'],
      salary: '\$6,500 - \$9,200',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'rivet-sales-executive',
      company: 'Rivet Industrial',
      companyTag: 'Enterprise',
      matchPercent: 69,
      title: 'Account Executive',
      level: 'Intermediate',
      location: 'Austin, TX',
      timeAgo: '1 day ago',
      description:
          'Own the full sales cycle for industrial software accounts in North America.',
      tags: ['Sales', 'B2B', 'CRM', 'Negotiation'],
      salary: '\$4,000 - \$7,000',
      distance: '9.4 km away',
    ),
    JobFeedModel(
      id: 'solace-content-strategist',
      company: 'Solace Health',
      companyTag: 'Verified',
      matchPercent: 80,
      title: 'Content Strategist',
      level: 'Senior',
      location: 'Remote',
      timeAgo: '1 day ago',
      description:
          'Define clear content systems for a trusted health and wellness platform.',
      tags: ['Content Strategy', 'SEO', 'UX Writing', 'Research'],
      salary: '\$4,400 - \$6,200',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'tandem-project-manager',
      company: 'Tandem Build',
      companyTag: 'Agency',
      matchPercent: 83,
      title: 'Technical Project Manager',
      level: 'Senior',
      location: 'Washington, DC',
      timeAgo: '1 day ago',
      description:
          'Coordinate delivery across design, engineering, and client stakeholders.',
      tags: ['Project Management', 'Agile', 'Jira', 'Delivery'],
      salary: '\$5,000 - \$7,400',
      distance: '7.1 km away',
    ),
    JobFeedModel(
      id: 'uplift-finance-analyst',
      company: 'Uplift Ventures',
      companyTag: 'Featured',
      matchPercent: 77,
      title: 'Financial Analyst',
      level: 'Intermediate',
      location: 'Singapore',
      timeAgo: '2 days ago',
      description:
          'Build forecasts and reporting for fast-moving investment and operations teams.',
      tags: ['Excel', 'Finance', 'Forecasting', 'SQL'],
      salary: '\$3,700 - \$5,600',
      distance: '3.2 km away',
    ),
    JobFeedModel(
      id: 'vanta-support-engineer',
      company: 'Vanta Support',
      companyTag: 'Remote',
      matchPercent: 82,
      title: 'Technical Support Engineer',
      level: 'Mid-level',
      location: 'Remote',
      timeAgo: '2 days ago',
      description:
          'Resolve complex integration issues and improve self-service support tooling.',
      tags: ['APIs', 'Troubleshooting', 'SQL', 'Support'],
      salary: '\$3,800 - \$5,700',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'wildwood-brand-designer',
      company: 'Wildwood Collective',
      companyTag: 'Startup',
      matchPercent: 85,
      title: 'Brand Designer',
      level: 'Mid-level',
      location: 'Phnom Penh, Cambodia',
      timeAgo: '2 days ago',
      description:
          'Shape a memorable brand system across product, campaigns, and community events.',
      tags: ['Branding', 'Illustration', 'Figma', 'Campaigns'],
      salary: '\$1,900 - \$3,200',
      distance: '4.8 km away',
    ),
    JobFeedModel(
      id: 'xeno-data-engineer',
      company: 'Xeno Systems',
      companyTag: 'Enterprise',
      matchPercent: 87,
      title: 'Data Engineer',
      level: 'Senior',
      location: 'New York, NY',
      timeAgo: '2 days ago',
      description:
          'Build dependable pipelines and data models for real-time operational reporting.',
      tags: ['Python', 'Spark', 'Airflow', 'Snowflake'],
      salary: '\$6,200 - \$8,800',
      distance: '5.9 km away',
    ),
    JobFeedModel(
      id: 'yardbird-operations-lead',
      company: 'Yardbird Logistics',
      companyTag: 'Verified',
      matchPercent: 74,
      title: 'Operations Lead',
      level: 'Senior',
      location: 'Bangkok, Thailand',
      timeAgo: '3 days ago',
      description:
          'Improve dispatch, fulfillment, and vendor processes across a regional network.',
      tags: ['Operations', 'Logistics', 'Process Design', 'Leadership'],
      salary: '\$3,300 - \$4,900',
      distance: '15.0 km away',
    ),
    JobFeedModel(
      id: 'zephyr-community-manager',
      company: 'Zephyr Games',
      companyTag: 'Featured',
      matchPercent: 79,
      title: 'Community Manager',
      level: 'Intermediate',
      location: 'Remote',
      timeAgo: '3 days ago',
      description:
          'Build inclusive player communities and turn feedback into actionable product insight.',
      tags: ['Community', 'Social Media', 'Gaming', 'Events'],
      salary: '\$3,000 - \$4,600',
      distance: 'Fully remote',
    ),
    JobFeedModel(
      id: 'arcade-frontend-intern',
      company: 'Arcade Labs',
      companyTag: 'Startup',
      matchPercent: 71,
      title: 'Frontend Engineering Intern',
      level: 'Entry-level',
      location: 'Singapore',
      timeAgo: '4 days ago',
      description:
          'Learn modern frontend practices while helping ship experiments for a creator platform.',
      tags: ['JavaScript', 'React', 'CSS', 'Git'],
      salary: '\$2,800 - \$3,600',
      distance: '5.1 km away',
    ),
  ];

  void selectTab(int index) {
    selectedTab.value = index;
    _storage.write(_selectedTabKey, index);
    _resetPagination();
  }

  /// Resolves a job [id] back to its full model, or null if no job matches.
  /// Used by saved/applications screens that persist only ids.
  JobFeedModel? jobById(String id) {
    for (final job in jobs) {
      if (job.id == id) {
        return job;
      }
    }
    return null;
  }

  List<JobFeedModel> get filteredJobs {
    final query = searchQuery.value.trim().toLowerCase();
    final level = selectedLevel.value;
    final location = selectedLocation.value;
    final minSalary = minSalaryFilter.value.round();
    final maxSalary = maxSalaryFilter.value.round();

    // Tab filtering: 0 = All Jobs, 1 = Best Matches (≥90%), 2 = Saved Jobs.
    final tab = selectedTab.value;
    final savedIds = tab == 2 ? Get.find<SavedJobsController>().savedIds : null;

    return jobs.where((job) {
      if (dismissedJobIds.contains(job.id)) {
        return false;
      }

      if (tab == 1 && job.matchPercent < 90) {
        return false;
      }
      if (tab == 2 && (savedIds == null || !savedIds.contains(job.id))) {
        return false;
      }

      if (level != null && job.level != level) {
        return false;
      }

      if (location != null && job.location != location) {
        return false;
      }

      final salaryRange = _parseSalaryRange(job.salary);
      if (salaryRange.$2 < minSalary || salaryRange.$1 > maxSalary) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        job.company,
        job.companyTag,
        job.title,
        job.level,
        job.location,
        job.description,
        job.salary,
        job.distance,
        ...job.tags,
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  List<String> get levels {
    final values = jobs.map((job) => job.level).toSet().toList();
    if (!values.contains('Internship')) {
      values.add('Internship');
    }
    return values;
  }

  List<String> get locations =>
      jobs.map((job) => job.location).toSet().toList();

  int get minAvailableSalary => jobs
      .map((job) => _parseSalaryRange(job.salary).$1)
      .reduce((value, element) => value < element ? value : element);

  int get maxAvailableSalary => jobs
      .map((job) => _parseSalaryRange(job.salary).$2)
      .reduce((value, element) => value > element ? value : element);

  bool get hasCustomSalaryRange =>
      minSalaryFilter.value.round() != minAvailableSalary ||
      maxSalaryFilter.value.round() != maxAvailableSalary;

  bool get hasActiveFilters =>
      selectedLevel.value != null ||
      selectedLocation.value != null ||
      hasCustomSalaryRange;

  void selectLevel(String? value) {
    selectedLevel.value = selectedLevel.value == value ? null : value;
    _resetPagination();
  }

  void selectLocation(String? value) {
    selectedLocation.value = selectedLocation.value == value ? null : value;
    _resetPagination();
  }

  void updateSalaryRange(double start, double end) {
    minSalaryFilter.value = start;
    maxSalaryFilter.value = end;
    _resetPagination();
  }

  void clearFilters() {
    selectedLevel.value = null;
    selectedLocation.value = null;
    minSalaryFilter.value = minAvailableSalary.toDouble();
    maxSalaryFilter.value = maxAvailableSalary.toDouble();
    _resetPagination();
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    _resetPagination();
  }

  void clearSearch() {
    searchQuery.value = '';
    _resetPagination();
  }

  (int, int) _parseSalaryRange(String salary) {
    try {
      final amounts = RegExp(r'[\d,]+').allMatches(salary).map((match) {
        return int.parse(match.group(0)!.replaceAll(',', ''));
      }).toList();

      if (amounts.isEmpty) return (0, 0);
      if (amounts.length == 1) return (amounts.first, amounts.first);
      return (amounts.first, amounts[1]);
    } on FormatException {
      debugPrint('Failed to parse salary: "$salary"');
      return (0, 0);
    }
  }
}
