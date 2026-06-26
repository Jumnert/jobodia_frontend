import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

void main() {
  group('CvWorkExperience', () {
    const work = CvWorkExperience(
      role: 'Developer',
      company: 'Acme',
      start: 'Jan 2023',
      end: 'Dec 2023',
      description: 'Built things.',
    );

    test('toJson/fromJson round-trip', () {
      final json = work.toJson();
      final restored = CvWorkExperience.fromJson(json);

      expect(restored.role, 'Developer');
      expect(restored.company, 'Acme');
      expect(restored.start, 'Jan 2023');
      expect(restored.end, 'Dec 2023');
      expect(restored.description, 'Built things.');
    });

    test('isEmpty returns true when all fields are empty', () {
      const empty = CvWorkExperience(
        role: '',
        company: '',
        start: '',
        end: '',
        description: '',
      );
      expect(empty.isEmpty, isTrue);
    });

    test('isEmpty returns false when role is set', () {
      const notEmpty = CvWorkExperience(
        role: 'Dev',
        company: '',
        start: '',
        end: '',
        description: '',
      );
      expect(notEmpty.isEmpty, isFalse);
    });

    test('dateRange formats start - end', () {
      expect(work.dateRange, 'Jan 2023 - Dec 2023');
    });

    test('dateRange shows "Present" when end is empty', () {
      const ongoing = CvWorkExperience(
        role: 'Dev',
        company: 'X',
        start: 'Jan 2023',
        end: '',
        description: '',
      );
      expect(ongoing.dateRange, 'Jan 2023 - Present');
    });

    test('dateRange returns empty when both start and end are empty', () {
      const noDates = CvWorkExperience(
        role: 'Dev',
        company: 'X',
        start: '',
        end: '',
        description: '',
      );
      expect(noDates.dateRange, '');
    });

    test(
      'isDateRangeEmpty returns true when start, end, and description are empty',
      () {
        const noDates = CvWorkExperience(
          role: 'Dev',
          company: 'X',
          start: '',
          end: '',
          description: '',
        );
        expect(noDates.isDateRangeEmpty, isTrue);
      },
    );

    test('isDateRangeEmpty returns false when description is set', () {
      const withDesc = CvWorkExperience(
        role: '',
        company: '',
        start: '',
        end: '',
        description: 'Something',
      );
      expect(withDesc.isDateRangeEmpty, isFalse);
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = CvWorkExperience.fromJson(<String, dynamic>{});

      expect(restored.role, '');
      expect(restored.company, '');
      expect(restored.start, '');
      expect(restored.end, '');
      expect(restored.description, '');
    });
  });

  group('CvEducation', () {
    const edu = CvEducation(
      school: 'RUPP',
      degree: 'BSc CS',
      start: 'Sep 2019',
      end: 'Jun 2023',
      description: 'Studied CS.',
    );

    test('toJson/fromJson round-trip', () {
      final json = edu.toJson();
      final restored = CvEducation.fromJson(json);

      expect(restored.school, 'RUPP');
      expect(restored.degree, 'BSc CS');
      expect(restored.start, 'Sep 2019');
      expect(restored.end, 'Jun 2023');
      expect(restored.description, 'Studied CS.');
    });

    test('isEmpty returns true when all fields are empty', () {
      const empty = CvEducation(
        school: '',
        degree: '',
        start: '',
        end: '',
        description: '',
      );
      expect(empty.isEmpty, isTrue);
    });

    test('isEmpty returns false when school is set', () {
      const notEmpty = CvEducation(
        school: 'MIT',
        degree: '',
        start: '',
        end: '',
        description: '',
      );
      expect(notEmpty.isEmpty, isFalse);
    });

    test('dateRange formats correctly', () {
      expect(edu.dateRange, 'Sep 2019 - Jun 2023');
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = CvEducation.fromJson(<String, dynamic>{});

      expect(restored.school, '');
      expect(restored.degree, '');
    });
  });

  group('CvData', () {
    const cv = CvData(
      fullName: 'John Doe',
      title: 'Flutter Developer',
      email: 'john@example.com',
      phone: '+855123456789',
      location: 'Phnom Penh',
      summary: 'Experienced developer.',
      templateIndex: 1,
      skills: ['Flutter', 'Dart'],
      workExperiences: [
        CvWorkExperience(
          role: 'Dev',
          company: 'Acme',
          start: 'Jan 2023',
          end: '',
          description: 'Building apps.',
        ),
      ],
      educations: [
        CvEducation(
          school: 'RUPP',
          degree: 'BSc',
          start: '2019',
          end: '2023',
          description: 'CS degree.',
        ),
      ],
    );

    test('toJson/fromJson round-trip preserves all fields', () {
      final json = cv.toJson();
      final restored = CvData.fromJson(json);

      expect(restored.fullName, cv.fullName);
      expect(restored.title, cv.title);
      expect(restored.email, cv.email);
      expect(restored.phone, cv.phone);
      expect(restored.location, cv.location);
      expect(restored.summary, cv.summary);
      expect(restored.templateIndex, cv.templateIndex);
      expect(restored.skills, cv.skills);
      expect(restored.workExperiences.length, 1);
      expect(restored.workExperiences.first.role, 'Dev');
      expect(restored.educations.length, 1);
      expect(restored.educations.first.school, 'RUPP');
      expect(restored.headshotBytes, isNull);
    });

    test('hasHeadshot returns false when no headshot', () {
      expect(cv.hasHeadshot, isFalse);
    });

    test('hasHeadshot returns true with non-empty bytes', () {
      final withPhoto = CvData(
        fullName: cv.fullName,
        title: cv.title,
        email: cv.email,
        phone: cv.phone,
        location: cv.location,
        summary: cv.summary,
        templateIndex: cv.templateIndex,
        skills: cv.skills,
        workExperiences: cv.workExperiences,
        educations: cv.educations,
        headshotBytes: Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]),
      );

      expect(withPhoto.hasHeadshot, isTrue);
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = CvData.fromJson(<String, dynamic>{});

      expect(restored.fullName, '');
      expect(restored.title, '');
      expect(restored.skills, isEmpty);
      expect(restored.workExperiences, isEmpty);
      expect(restored.educations, isEmpty);
      expect(restored.templateIndex, 0);
    });
  });
}
