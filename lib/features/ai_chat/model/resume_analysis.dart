class ResumeScoreCategory {
  const ResumeScoreCategory({
    required this.id,
    required this.label,
    required this.score,
    required this.maxScore,
    required this.reason,
  });

  final String id;
  final String label;
  final int score;
  final int maxScore;
  final String reason;

  double get progress => maxScore == 0 ? 0 : score / maxScore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'score': score,
    'maxScore': maxScore,
    'reason': reason,
  };

  factory ResumeScoreCategory.fromJson(Map<String, dynamic> json) {
    final maxScore = _asInt(json['maxScore']).clamp(1, 100);
    return ResumeScoreCategory(
      id: json['id']?.toString().trim() ?? '',
      label: json['label']?.toString().trim() ?? 'Resume quality',
      score: _asInt(json['score']).clamp(0, maxScore),
      maxScore: maxScore,
      reason: json['reason']?.toString().trim() ?? '',
    );
  }
}

class ResumePriorityFix {
  const ResumePriorityFix({
    required this.title,
    required this.why,
    required this.action,
  });

  final String title;
  final String why;
  final String action;

  Map<String, dynamic> toJson() => {
    'title': title,
    'why': why,
    'action': action,
  };

  factory ResumePriorityFix.fromJson(Map<String, dynamic> json) {
    return ResumePriorityFix(
      title: json['title']?.toString().trim() ?? 'Improve this section',
      why: json['why']?.toString().trim() ?? '',
      action: json['action']?.toString().trim() ?? '',
    );
  }
}

class ResumeRewrite {
  const ResumeRewrite({required this.original, required this.improved});

  final String original;
  final String improved;

  Map<String, dynamic> toJson() => {'original': original, 'improved': improved};

  factory ResumeRewrite.fromJson(Map<String, dynamic> json) => ResumeRewrite(
    original: json['original']?.toString().trim() ?? '',
    improved: json['improved']?.toString().trim() ?? '',
  );
}

class ResumeAnalysis {
  const ResumeAnalysis({
    required this.summary,
    required this.categories,
    required this.strengths,
    required this.priorityFixes,
    required this.rewrites,
    required this.missingInformation,
    this.targetRoleFit,
    this.targetRole,
  });

  static const rubricVersion = 1;

  static const expectedCategories = <String, (String, int)>{
    'contact_structure': ('Contact & structure', 15),
    'professional_summary': ('Professional summary', 15),
    'experience_impact': ('Experience & impact', 25),
    'skills_relevance': ('Skills & relevance', 20),
    'education_qualifications': ('Education & qualifications', 10),
    'readability_ats': ('Readability & ATS readiness', 15),
  };

  final String summary;
  final List<ResumeScoreCategory> categories;
  final List<String> strengths;
  final List<ResumePriorityFix> priorityFixes;
  final List<ResumeRewrite> rewrites;
  final List<String> missingInformation;
  final String? targetRoleFit;
  final String? targetRole;

  int get overallScore => categories.fold(0, (sum, item) => sum + item.score);

  int get maximumScore =>
      categories.fold(0, (sum, item) => sum + item.maxScore);

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'categories': categories.map((item) => item.toJson()).toList(),
    'strengths': strengths,
    'priorityFixes': priorityFixes.map((item) => item.toJson()).toList(),
    'rewrites': rewrites.map((item) => item.toJson()).toList(),
    'missingInformation': missingInformation,
    if (targetRoleFit != null) 'targetRoleFit': targetRoleFit,
    if (targetRole != null) 'targetRole': targetRole,
  };

  factory ResumeAnalysis.fromJson(
    Map<String, dynamic> json, {
    String? targetRole,
  }) {
    final rawCategories = _mapList(json['categories']);
    final received = <String, ResumeScoreCategory>{};
    for (final raw in rawCategories) {
      final category = ResumeScoreCategory.fromJson(raw);
      if (ResumeAnalysis.expectedCategories.containsKey(category.id)) {
        received[category.id] = category;
      }
    }

    final categories = expectedCategories.entries
        .map((entry) {
          final expected = entry.value;
          final supplied = received[entry.key];
          return ResumeScoreCategory(
            id: entry.key,
            label: expected.$1,
            score: (supplied?.score ?? 0).clamp(0, expected.$2),
            maxScore: expected.$2,
            reason: supplied?.reason ?? 'Not enough information was provided.',
          );
        })
        .toList(growable: false);

    final summary = json['summary']?.toString().trim() ?? '';
    if (summary.isEmpty || received.length != expectedCategories.length) {
      throw const FormatException('Incomplete resume analysis response.');
    }

    return ResumeAnalysis(
      summary: summary,
      categories: categories,
      strengths: _stringList(json['strengths']).take(5).toList(),
      priorityFixes: _priorityFixList(json['priorityFixes']).take(5).toList(),
      rewrites: _mapList(json['rewrites'])
          .map(ResumeRewrite.fromJson)
          .where((item) => item.original.isNotEmpty && item.improved.isNotEmpty)
          .take(3)
          .toList(),
      missingInformation: _stringList(
        json['missingInformation'],
      ).take(5).toList(),
      targetRoleFit: _nullableText(json['targetRoleFit']),
      targetRole: _nullableText(targetRole),
    );
  }
}

int _asInt(Object? value) {
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<ResumePriorityFix> _priorityFixList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is Map) {
          return ResumePriorityFix.fromJson(Map<String, dynamic>.from(item));
        }
        final text = item.toString().trim();
        return ResumePriorityFix(title: text, why: '', action: '');
      })
      .where((item) => item.title.isNotEmpty)
      .toList();
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
