class JobFeedModel {
  const JobFeedModel({
    required this.id,
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

  /// Stable unique identifier used to track saved/applied state and persist
  /// references. Stays constant for a given job across sessions.
  final String id;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'companyTag': companyTag,
    'matchPercent': matchPercent,
    'title': title,
    'level': level,
    'location': location,
    'timeAgo': timeAgo,
    'description': description,
    'tags': tags,
    'salary': salary,
    'distance': distance,
  };

  factory JobFeedModel.fromJson(Map<String, dynamic> json) => JobFeedModel(
    id: json['id'] as String,
    company: json['company'] as String,
    companyTag: json['companyTag'] as String,
    matchPercent: json['matchPercent'] as int,
    title: json['title'] as String,
    level: json['level'] as String,
    location: json['location'] as String,
    timeAgo: json['timeAgo'] as String,
    description: json['description'] as String,
    tags: (json['tags'] as List<dynamic>).cast<String>(),
    salary: json['salary'] as String,
    distance: json['distance'] as String,
  );
}
