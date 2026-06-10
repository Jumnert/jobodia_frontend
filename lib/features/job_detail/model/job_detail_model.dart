class JobDetailModel {
  const JobDetailModel({
    required this.title,
    required this.companyName,
    required this.postedDate,
    required this.workMode,
    required this.category,
    required this.department,
    required this.heroImageUrl,
    required this.description,
    required this.aboutRole,
    required this.moreJobs,
  });

  final String title;
  final String companyName;
  final String postedDate;
  final String workMode;
  final String category;
  final String department;
  final String heroImageUrl;
  final String description;
  final String aboutRole;
  final List<RelatedJobModel> moreJobs;

  List<String> get tags => [workMode, category, department];
}

class RelatedJobModel {
  const RelatedJobModel({
    required this.title,
    required this.workMode,
    required this.department,
  });

  final String title;
  final String workMode;
  final String department;
}
