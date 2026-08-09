class JobPostDraft {
  const JobPostDraft({
    required this.title,
    required this.company,
    required this.location,
    required this.workArrangement,
    required this.employmentType,
    required this.experienceLevel,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.tags,
    this.applicationStartDate = '',
    this.applicationEndDate = '',
  });

  final String title;
  final String company;
  final String location;
  final String workArrangement;
  final String employmentType;
  final String experienceLevel;
  final String salary;
  final String description;
  final String requirements;
  final String tags;
  final String applicationStartDate;
  final String applicationEndDate;

  bool get isEmpty => [
    title,
    company,
    location,
    salary,
    description,
    requirements,
    tags,
  ].every((value) => value.trim().isEmpty);

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'location': location,
    'workArrangement': workArrangement,
    'employmentType': employmentType,
    'experienceLevel': experienceLevel,
    'salary': salary,
    'description': description,
    'requirements': requirements,
    'tags': tags,
    'applicationStartDate': applicationStartDate,
    'applicationEndDate': applicationEndDate,
  };

  factory JobPostDraft.fromJson(Map<String, dynamic> json) => JobPostDraft(
    title: json['title'] as String? ?? '',
    company: json['company'] as String? ?? '',
    location: json['location'] as String? ?? '',
    workArrangement: json['workArrangement'] as String? ?? 'On-site',
    employmentType: json['employmentType'] as String? ?? 'Full-time',
    experienceLevel: json['experienceLevel'] as String? ?? 'Mid-level',
    salary: json['salary'] as String? ?? '',
    description: json['description'] as String? ?? '',
    requirements: json['requirements'] as String? ?? '',
    tags: json['tags'] as String? ?? '',
    applicationStartDate: json['applicationStartDate'] as String? ?? '',
    applicationEndDate: json['applicationEndDate'] as String? ?? '',
  );
}
