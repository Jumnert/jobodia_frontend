import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

void main() {
  group('JobFeedModel', () {
    const sample = JobFeedModel(
      id: 'job-001',
      company: 'Acme Corp',
      companyTag: 'acme',
      matchPercent: 85,
      title: 'Flutter Developer',
      level: 'Senior',
      location: 'Phnom Penh',
      timeAgo: '2 days ago',
      description: 'Build mobile apps with Flutter.',
      tags: ['Flutter', 'Dart', 'Firebase'],
      salary: '\$1500 - \$2500',
      distance: '3.5 km away',
    );

    test('toJson preserves all fields', () {
      final json = sample.toJson();

      expect(json['id'], 'job-001');
      expect(json['company'], 'Acme Corp');
      expect(json['companyTag'], 'acme');
      expect(json['matchPercent'], 85);
      expect(json['title'], 'Flutter Developer');
      expect(json['level'], 'Senior');
      expect(json['location'], 'Phnom Penh');
      expect(json['timeAgo'], '2 days ago');
      expect(json['description'], 'Build mobile apps with Flutter.');
      expect(json['tags'], ['Flutter', 'Dart', 'Firebase']);
      expect(json['salary'], '\$1500 - \$2500');
      expect(json['distance'], '3.5 km away');
    });

    test('fromJson restores all fields', () {
      final json = sample.toJson();
      final restored = JobFeedModel.fromJson(json);

      expect(restored.id, sample.id);
      expect(restored.company, sample.company);
      expect(restored.companyTag, sample.companyTag);
      expect(restored.matchPercent, sample.matchPercent);
      expect(restored.title, sample.title);
      expect(restored.level, sample.level);
      expect(restored.location, sample.location);
      expect(restored.timeAgo, sample.timeAgo);
      expect(restored.description, sample.description);
      expect(restored.tags, sample.tags);
      expect(restored.salary, sample.salary);
      expect(restored.distance, sample.distance);
    });

    test('toJson -> fromJson round-trip is lossless', () {
      final json = sample.toJson();
      final restored = JobFeedModel.fromJson(json);
      final jsonAgain = restored.toJson();

      expect(jsonAgain, json);
    });

    test('fromJson handles empty tags list', () {
      final json = sample.toJson();
      json['tags'] = <String>[];
      final restored = JobFeedModel.fromJson(json);

      expect(restored.tags, isEmpty);
    });

    test('fromJson throws on missing required fields', () {
      // id is required with `as String` cast, so missing it should throw.
      final json = sample.toJson()..remove('id');

      expect(() => JobFeedModel.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('fromJson handles large matchPercent', () {
      final json = sample.toJson();
      json['matchPercent'] = 100;
      final restored = JobFeedModel.fromJson(json);

      expect(restored.matchPercent, 100);
    });
  });
}
