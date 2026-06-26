import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

class ResumeParserService {
  Future<Map<String, dynamic>> parseResumeMock() async {
    await Future<void>.delayed(const Duration(seconds: 3));

    return {
      'fullName': 'Alex Johnson',
      'email': 'alex.j@example.com',
      'phone': '+1 234 567 890',
      'location': 'San Francisco, CA',
      'title': 'Senior Flutter Developer',
      'summary':
          'Experienced software engineer specializing in Flutter and mobile app development.',
      'school': 'Stanford University',
      'degree': 'B.S. Computer Science',
      'eduStart': '2016',
      'eduEnd': '2020',
      'company': 'Tech Corp',
      'role': 'Senior Mobile Developer',
      'workStart': '2020',
      'workEnd': 'Present',
      'workDesc':
          'Lead developer for main consumer app. Increased retention by 20%.',
      'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
    };
  }
}
