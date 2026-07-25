import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/cv_builder/service/cv_pdf_builder.dart';

void main() {
  test('all CV templates generate real PDF bytes', () async {
    for (var template = 0; template < 3; template++) {
      final cv = CvData(
        fullName: 'Alex Johnson',
        title: 'Flutter Developer',
        email: 'alex@example.com',
        phone: '+855 12 345 678',
        location: 'Phnom Penh, Cambodia',
        summary: 'Mobile developer focused on reliable, accessible products.',
        templateIndex: template,
        skills: const ['Flutter', 'Dart', 'GetX'],
        workExperiences: const [
          CvWorkExperience(
            role: 'Flutter Developer',
            company: 'Jobodia',
            start: 'Jan 2024',
            end: '',
            description: 'Built and shipped mobile product experiences.',
          ),
        ],
        educations: const [
          CvEducation(
            school: 'Royal University of Phnom Penh',
            degree: 'Computer Science',
            start: '2020',
            end: '2024',
            description: '',
          ),
        ],
      );

      final bytes = await buildCvPdf(cv);
      final signature = String.fromCharCodes(bytes.take(4));

      expect(signature, '%PDF');
      expect(bytes.length, greaterThan(1000));
    }
  });
}
