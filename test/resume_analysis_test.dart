import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/ai_chat/model/resume_analysis.dart';

void main() {
  Map<String, dynamic> validJson() => {
    'summary': 'Clear resume with room for stronger impact statements.',
    'categories': [
      {
        'id': 'contact_structure',
        'score': 13,
        'maxScore': 15,
        'reason': 'Contact details are present.',
      },
      {
        'id': 'professional_summary',
        'score': 10,
        'maxScore': 15,
        'reason': 'The summary is relevant.',
      },
      {
        'id': 'experience_impact',
        'score': 18,
        'maxScore': 25,
        'reason': 'Experience is clear but lightly quantified.',
      },
      {
        'id': 'skills_relevance',
        'score': 16,
        'maxScore': 20,
        'reason': 'Skills match the role.',
      },
      {
        'id': 'education_qualifications',
        'score': 8,
        'maxScore': 10,
        'reason': 'Education is clearly listed.',
      },
      {
        'id': 'readability_ats',
        'score': 12,
        'maxScore': 15,
        'reason': 'The content is easy to scan.',
      },
    ],
    'strengths': ['Relevant Flutter skills'],
    'priorityFixes': [
      {
        'title': 'Quantify impact',
        'why': 'Results are not measurable.',
        'action': 'Add truthful metrics where available.',
      },
    ],
    'rewrites': [
      {
        'original': 'Worked on mobile apps',
        'improved': 'Built and maintained Flutter mobile applications',
      },
    ],
    'missingInformation': ['Portfolio link'],
    'targetRoleFit': 'Good match for a Flutter Developer role.',
  };

  test('recomputes overall score from the fixed rubric', () {
    final analysis = ResumeAnalysis.fromJson(
      validJson(),
      targetRole: 'Flutter Developer',
    );

    expect(analysis.overallScore, 77);
    expect(analysis.maximumScore, 100);
    expect(analysis.categories, hasLength(6));
    expect(analysis.targetRole, 'Flutter Developer');
  });

  test('clamps category score to the trusted rubric maximum', () {
    final json = validJson();
    final categories = json['categories'] as List<dynamic>;
    (categories.first as Map<String, dynamic>)['score'] = 999;
    (categories.first as Map<String, dynamic>)['maxScore'] = 999;

    final analysis = ResumeAnalysis.fromJson(json);

    expect(analysis.categories.first.score, 15);
    expect(analysis.categories.first.maxScore, 15);
  });

  test('rejects a response with missing rubric categories', () {
    final json = validJson();
    (json['categories'] as List<dynamic>).removeLast();

    expect(() => ResumeAnalysis.fromJson(json), throwsFormatException);
  });

  test('survives JSON serialization for secure chat history', () {
    final original = ResumeAnalysis.fromJson(
      validJson(),
      targetRole: 'Flutter Developer',
    );
    final restored = ResumeAnalysis.fromJson(
      original.toJson(),
      targetRole: original.targetRole,
    );

    expect(restored.overallScore, original.overallScore);
    expect(restored.priorityFixes.first.title, 'Quantify impact');
    expect(restored.rewrites.first.improved, contains('Flutter'));
  });

  test('accepts shortened string fixes from JSON mode', () {
    final json = validJson();
    json['priorityFixes'] = ['Add measurable outcomes'];

    final analysis = ResumeAnalysis.fromJson(json);

    expect(analysis.priorityFixes.single.title, 'Add measurable outcomes');
  });
}
