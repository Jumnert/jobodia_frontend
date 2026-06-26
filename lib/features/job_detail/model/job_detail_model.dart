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

  Map<String, dynamic> toJson() => {
    'title': title,
    'companyName': companyName,
    'postedDate': postedDate,
    'workMode': workMode,
    'category': category,
    'department': department,
    'heroImageUrl': heroImageUrl,
    'description': description,
    'aboutRole': aboutRole,
    'moreJobs': moreJobs.map((j) => j.toJson()).toList(),
  };

  factory JobDetailModel.fromJson(Map<String, dynamic> json) => JobDetailModel(
    title: json['title'] as String,
    companyName: json['companyName'] as String,
    postedDate: json['postedDate'] as String,
    workMode: json['workMode'] as String,
    category: json['category'] as String,
    department: json['department'] as String,
    heroImageUrl: json['heroImageUrl'] as String,
    description: json['description'] as String,
    aboutRole: json['aboutRole'] as String,
    moreJobs: (json['moreJobs'] as List<dynamic>)
        .map((j) => RelatedJobModel.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'workMode': workMode,
    'department': department,
  };

  factory RelatedJobModel.fromJson(Map<String, dynamic> json) =>
      RelatedJobModel(
        title: json['title'] as String,
        workMode: json['workMode'] as String,
        department: json['department'] as String,
      );
}
