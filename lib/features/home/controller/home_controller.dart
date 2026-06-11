import 'package:get/get.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

class HomeController extends GetxController {
  final RxInt selectedTab = 1.obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedLevel = RxnString();
  final RxnString selectedLocation = RxnString();
  final RxDouble minSalaryFilter = 2800.0.obs;
  final RxDouble maxSalaryFilter = 7200.0.obs;

  final jobs = const <JobFeedModel>[
    JobFeedModel(
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
      proposals: '9 proposals',
    ),
    JobFeedModel(
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
      proposals: '3 proposals',
    ),
    JobFeedModel(
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
      proposals: '6 proposals',
    ),
    JobFeedModel(
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
      proposals: '11 proposals',
    ),
  ];

  void selectTab(int index) {
    selectedTab.value = index;
  }

  List<JobFeedModel> get filteredJobs {
    final query = searchQuery.value.trim().toLowerCase();
    final level = selectedLevel.value;
    final location = selectedLocation.value;
    final minSalary = minSalaryFilter.value.round();
    final maxSalary = maxSalaryFilter.value.round();

    return jobs.where((job) {
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
        job.proposals,
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
  }

  void selectLocation(String? value) {
    selectedLocation.value = selectedLocation.value == value ? null : value;
  }

  void updateSalaryRange(double start, double end) {
    minSalaryFilter.value = start;
    maxSalaryFilter.value = end;
  }

  void clearFilters() {
    selectedLevel.value = null;
    selectedLocation.value = null;
    minSalaryFilter.value = minAvailableSalary.toDouble();
    maxSalaryFilter.value = maxAvailableSalary.toDouble();
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  (int, int) _parseSalaryRange(String salary) {
    final amounts = RegExp(r'[\d,]+').allMatches(salary).map((match) {
      return int.parse(match.group(0)!.replaceAll(',', ''));
    }).toList();

    if (amounts.isEmpty) {
      return (0, 0);
    }

    if (amounts.length == 1) {
      return (amounts.first, amounts.first);
    }

    return (amounts.first, amounts[1]);
  }
}
