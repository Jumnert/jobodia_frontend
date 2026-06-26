class JobAlertModel {
  const JobAlertModel({
    required this.id,
    required this.name,
    required this.keywords,
    this.location,
    this.level,
    this.minSalary,
    required this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String name;
  final List<String> keywords;
  final String? location;
  final String? level;
  final int? minSalary;
  final DateTime createdAt;
  final bool isActive;

  JobAlertModel copyWith({
    String? id,
    String? name,
    List<String>? keywords,
    String? location,
    String? level,
    int? minSalary,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return JobAlertModel(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
      location: location ?? this.location,
      level: level ?? this.level,
      minSalary: minSalary ?? this.minSalary,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keywords': keywords,
      'location': location,
      'level': level,
      'minSalary': minSalary,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory JobAlertModel.fromJson(Map<String, dynamic> json) {
    return JobAlertModel(
      id: json['id'] as String,
      name: json['name'] as String,
      keywords: (json['keywords'] as List).cast<String>(),
      location: json['location'] as String?,
      level: json['level'] as String?,
      minSalary: json['minSalary'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
