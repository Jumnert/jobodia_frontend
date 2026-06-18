class JobFeedModel {
  const JobFeedModel({
    required this.company,
    required this.companyTag,
    required this.matchPercent,
    required this.title,
    required this.level,
    required this.location,
    required this.timeAgo,
    required this.description,
    required this.tags,
    required this.salary,
    required this.distance,
  });

  final String company;
  final String companyTag;
  final int matchPercent;
  final String title;
  final String level;
  final String location;
  final String timeAgo;
  final String description;
  final List<String> tags;
  final String salary;

  /// Distance of the job from the seeker's current location, e.g. "3.5 km away".
  final String distance;
}
