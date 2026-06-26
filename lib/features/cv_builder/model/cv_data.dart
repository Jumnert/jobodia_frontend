import 'dart:convert';
import 'dart:typed_data';

/// Shared date-range logic for CV entries that have `start`/`end` fields.
mixin CvDateRangeMixin {
  String get start;
  String get end;
  String get description;

  bool get isDateRangeEmpty =>
      start.isEmpty && end.isEmpty && description.isEmpty;

  String get dateRange {
    if (start.isEmpty && end.isEmpty) return '';
    if (end.isEmpty) return '$start - Present';
    if (start.isEmpty) return end;
    return '$start - $end';
  }
}

class CvWorkExperience with CvDateRangeMixin {
  const CvWorkExperience({
    required this.role,
    required this.company,
    required this.start,
    required this.end,
    required this.description,
  });

  final String role;
  final String company;
  @override
  final String start;
  @override
  final String end;
  @override
  final String description;

  bool get isEmpty => role.isEmpty && company.isEmpty && isDateRangeEmpty;

  Map<String, dynamic> toJson() => {
    'role': role,
    'company': company,
    'start': start,
    'end': end,
    'description': description,
  };

  factory CvWorkExperience.fromJson(Map<String, dynamic> json) =>
      CvWorkExperience(
        role: json['role'] as String? ?? '',
        company: json['company'] as String? ?? '',
        start: json['start'] as String? ?? '',
        end: json['end'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

class CvEducation with CvDateRangeMixin {
  const CvEducation({
    required this.school,
    required this.degree,
    required this.start,
    required this.end,
    required this.description,
  });

  final String school;
  final String degree;
  @override
  final String start;
  @override
  final String end;
  @override
  final String description;

  bool get isEmpty => school.isEmpty && degree.isEmpty && isDateRangeEmpty;

  Map<String, dynamic> toJson() => {
    'school': school,
    'degree': degree,
    'start': start,
    'end': end,
    'description': description,
  };

  factory CvEducation.fromJson(Map<String, dynamic> json) => CvEducation(
    school: json['school'] as String? ?? '',
    degree: json['degree'] as String? ?? '',
    start: json['start'] as String? ?? '',
    end: json['end'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class CvData {
  const CvData({
    required this.fullName,
    required this.title,
    required this.email,
    required this.phone,
    required this.location,
    required this.summary,
    required this.templateIndex,
    required this.skills,
    required this.workExperiences,
    required this.educations,
    this.headshotBytes,
  });

  final String fullName;
  final String title;
  final String email;
  final String phone;
  final String location;
  final String summary;
  final int templateIndex;
  final List<String> skills;
  final List<CvWorkExperience> workExperiences;
  final List<CvEducation> educations;

  /// Raw image bytes for the headshot. Null when no photo was chosen.
  final Uint8List? headshotBytes;

  bool get hasHeadshot => headshotBytes != null && headshotBytes!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'title': title,
    'email': email,
    'phone': phone,
    'location': location,
    'summary': summary,
    'templateIndex': templateIndex,
    'skills': skills,
    'workExperiences': workExperiences.map((e) => e.toJson()).toList(),
    'educations': educations.map((e) => e.toJson()).toList(),
    'headshot': headshotBytes == null ? null : base64Encode(headshotBytes!),
  };

  factory CvData.fromJson(Map<String, dynamic> json) {
    final headshot = json['headshot'] as String?;
    return CvData(
      fullName: json['fullName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      templateIndex: json['templateIndex'] as int? ?? 0,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          <String>[],
      workExperiences:
          (json['workExperiences'] as List<dynamic>?)
              ?.map((e) => CvWorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <CvWorkExperience>[],
      educations:
          (json['educations'] as List<dynamic>?)
              ?.map((e) => CvEducation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <CvEducation>[],
      headshotBytes: (headshot == null || headshot.isEmpty)
          ? null
          : base64Decode(headshot),
    );
  }
}
