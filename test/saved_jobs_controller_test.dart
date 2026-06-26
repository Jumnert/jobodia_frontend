import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

import 'saved_jobs_controller_test.mocks.dart';

@GenerateMocks([GetStorage])
void main() {
  late MockGetStorage mockStorage;

  final sampleJob = const JobFeedModel(
    id: 'job-1',
    company: 'Acme Corp',
    companyTag: 'Featured',
    matchPercent: 95,
    title: 'Flutter Developer',
    level: 'Senior',
    location: 'Remote',
    timeAgo: '1 hour ago',
    description: 'Build mobile apps.',
    tags: ['Flutter', 'Dart'],
    salary: '\$4,000 - \$6,000',
    distance: 'Fully remote',
  );

  final sampleJob2 = const JobFeedModel(
    id: 'job-2',
    company: 'Beta Inc',
    companyTag: 'Verified',
    matchPercent: 88,
    title: 'Backend Developer',
    level: 'Mid-level',
    location: 'Singapore',
    timeAgo: '3 hours ago',
    description: 'Build APIs.',
    tags: ['Node.js'],
    salary: '\$3,000 - \$5,000',
    distance: '2.1 km away',
  );

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();
    when(mockStorage.read<dynamic>('savedJobIds')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  SavedJobsController makeController() {
    final c = SavedJobsController(storage: mockStorage);
    c.onInit();
    return c;
  }

  group('SavedJobsController', () {
    test('initial state — no saved jobs', () {
      final c = makeController();
      expect(c.savedIds, isEmpty);
      expect(c.isSaved('job-1'), isFalse);
    });

    test('toggleSave adds a job id', () {
      final c = makeController();
      c.toggleSave(sampleJob);
      expect(c.isSaved('job-1'), isTrue);
      expect(c.savedIds.length, 1);
    });

    test('toggleSave removes a previously saved job id', () {
      final c = makeController();
      c.toggleSave(sampleJob); // add
      expect(c.isSaved('job-1'), isTrue);

      c.toggleSave(sampleJob); // remove
      expect(c.isSaved('job-1'), isFalse);
      expect(c.savedIds, isEmpty);
    });

    test('isSaved returns correct boolean', () {
      final c = makeController();
      expect(c.isSaved('job-1'), isFalse);
      c.toggleSave(sampleJob);
      expect(c.isSaved('job-1'), isTrue);
      expect(c.isSaved('job-2'), isFalse);
    });

    test('orderedSavedIds preserves most-recently-saved-first order', () {
      final c = makeController();
      c.toggleSave(sampleJob);
      c.toggleSave(sampleJob2);

      final ordered = c.orderedSavedIds;
      expect(ordered.length, 2);
      expect(ordered.first, 'job-2'); // most recently saved
      expect(ordered.last, 'job-1');
    });

    test('remove removes a specific saved id', () {
      final c = makeController();
      c.toggleSave(sampleJob);
      c.toggleSave(sampleJob2);
      c.remove('job-1');

      expect(c.isSaved('job-1'), isFalse);
      expect(c.isSaved('job-2'), isTrue);
      expect(c.savedIds.length, 1);
    });

    test('toggleSave persists to storage', () {
      final c = makeController();
      c.toggleSave(sampleJob);
      verify(mockStorage.write('savedJobIds', any)).called(greaterThan(0));
    });

    test('loads saved ids from storage on init', () {
      when(
        mockStorage.read<dynamic>('savedJobIds'),
      ).thenReturn(['job-1', 'job-2']);

      final c = SavedJobsController(storage: mockStorage);
      c.onInit();

      expect(c.savedIds.length, 2);
      expect(c.isSaved('job-1'), isTrue);
      expect(c.isSaved('job-2'), isTrue);
    });
  });
}
