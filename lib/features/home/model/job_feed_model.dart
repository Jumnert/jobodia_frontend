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
    this.requirementsText = '',
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

  /// Employer-written requirements for locally published jobs. Mock jobs fall
  /// back to the generated requirements below.
  final String requirementsText;

  String get fullDescription =>
      '$description\n\n'
      'As a $title at $company, you will join a collaborative team focused on '
      'delivering dependable work with clear customer and business impact. '
      'This $level opportunity is based in $location and gives you ownership '
      'from planning through delivery.';

  List<String> get responsibilities => [
    'Own key $title work from initial planning through final delivery.',
    'Collaborate with product, design, operations, and engineering partners.',
    'Turn business goals into practical, measurable outcomes.',
    'Share progress clearly and continuously improve team practices.',
  ];

  List<String> get requirements {
    final written = requirementsText
        .split(RegExp(r'[\n\r]+|(?<=\.)\s+'))
        .map((item) => item.replaceFirst(RegExp(r'^[-•]\s*'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (written.isNotEmpty) return written;

    return [
      '$level experience in a relevant role or equivalent practical work.',
      if (tags.isNotEmpty) 'Hands-on experience with ${tags.join(', ')}.',
      'Strong communication, prioritization, and problem-solving skills.',
      'Ability to work independently and contribute within a team.',
    ];
  }

  List<String> get benefits => [
    if (location.toLowerCase() == 'remote')
      'Remote-first work with flexible collaboration hours.'
    else
      'A supportive workplace in $location with flexible team practices.',
    'Clear ownership, regular feedback, and learning opportunities.',
    'Competitive compensation in the range of $salary.',
  ];

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
    'requirementsText': requirementsText,
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
    requirementsText: json['requirementsText'] as String? ?? '',
  );
}
