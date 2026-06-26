import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

import 'applications_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetStorage>()])
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

    when(mockStorage.read<dynamic>('applications')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);

    // Register a real SecureStorageService so _persist() can find it.
    // The real service uses flutter_secure_storage which won't work in tests,
    // but the writeSecure method catches exceptions silently.
    Get.put<SecureStorageService>(SecureStorageService());
  });

  tearDown(() {
    Get.reset();
  });

  ApplicationsController makeController() {
    final c = ApplicationsController(storage: mockStorage);
    c.onInit();
    return c;
  }

  group('ApplicationsController', () {
    test('initial state — no applications', () {
      final c = makeController();
      expect(c.applications, isEmpty);
      expect(c.hasApplied('job-1'), isFalse);
    });

    test('apply adds an application', () {
      final c = makeController();
      c.apply(sampleJob);

      expect(c.applications.length, 1);
      expect(c.applications.first.jobId, 'job-1');
      expect(c.hasApplied('job-1'), isTrue);
    });

    test('hasApplied returns true after apply', () {
      final c = makeController();
      expect(c.hasApplied('job-1'), isFalse);
      c.apply(sampleJob);
      expect(c.hasApplied('job-1'), isTrue);
    });

    test('apply is idempotent — no duplicate on second call', () {
      final c = makeController();
      c.apply(sampleJob);
      c.apply(sampleJob);
      expect(c.applications.length, 1);
    });

    test('updateStatus changes application status', () {
      final c = makeController();
      c.apply(sampleJob);
      expect(c.applicationFor('job-1')!.status, 'applied');

      c.updateStatus('job-1', 'interview');
      expect(c.applicationFor('job-1')!.status, 'interview');
    });

    test('updateStatus ignores invalid status', () {
      final c = makeController();
      c.apply(sampleJob);
      c.updateStatus('job-1', 'invalid_status');
      expect(c.applicationFor('job-1')!.status, 'applied');
    });

    test('updateStatus is no-op for unknown job id', () {
      final c = makeController();
      c.apply(sampleJob);
      c.updateStatus('nonexistent', 'interview');
      expect(c.applicationFor('job-1')!.status, 'applied');
    });

    test('applicationFor returns the correct application', () {
      final c = makeController();
      c.apply(sampleJob);
      c.apply(sampleJob2);

      final app = c.applicationFor('job-2');
      expect(app, isNotNull);
      expect(app!.jobId, 'job-2');
    });

    test('applicationFor returns null for unknown id', () {
      final c = makeController();
      expect(c.applicationFor('nonexistent'), isNull);
    });

    test('apply persists to storage', () {
      final c = makeController();
      c.apply(sampleJob);
      verify(mockStorage.write('applications', any)).called(greaterThan(0));
    });

    test('apply with cover letter stores it', () {
      final c = makeController();
      c.apply(sampleJob, coverLetter: 'Dear Hiring Manager...');
      final app = c.applicationFor('job-1');
      expect(app!.coverLetter, 'Dear Hiring Manager...');
    });
  });
}
