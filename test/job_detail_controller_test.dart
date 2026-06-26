import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

import 'job_detail_controller_test.mocks.dart';

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

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();

    when(mockStorage.read<dynamic>(any)).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);

    // Register a real SecureStorageService so _persist() can find it.
    Get.put<SecureStorageService>(SecureStorageService());
  });

  tearDown(() {
    Get.reset();
  });

  SavedJobsController registerSavedJobs() {
    final c = SavedJobsController(storage: mockStorage);
    c.onInit();
    Get.put<SavedJobsController>(c);
    return c;
  }

  ApplicationsController registerApplications() {
    final c = ApplicationsController(storage: mockStorage);
    c.onInit();
    Get.put<ApplicationsController>(c);
    return c;
  }

  group('JobDetailController', () {
    test('toggleSaved delegates to SavedJobsController', () {
      final saved = registerSavedJobs();
      registerApplications();

      final c = JobDetailController(source: sampleJob);
      expect(c.isSaved, isFalse);

      c.toggleSaved();

      expect(saved.isSaved('job-1'), isTrue);
    });

    test('isSaved reflects SavedJobsController state', () {
      final saved = registerSavedJobs();
      registerApplications();

      final c = JobDetailController(source: sampleJob);
      expect(c.isSaved, isFalse);

      saved.toggleSave(sampleJob);
      expect(c.isSaved, isTrue);
    });

    test('isApplied reflects ApplicationsController state', () {
      registerSavedJobs();
      final apps = registerApplications();

      final c = JobDetailController(source: sampleJob);
      expect(c.isApplied, isFalse);

      apps.apply(sampleJob);
      expect(c.isApplied, isTrue);
    });

    test('applyForJob is no-op when already applied', () async {
      registerSavedJobs();
      final apps = registerApplications();
      apps.apply(sampleJob);

      final c = JobDetailController(source: sampleJob);
      await c.applyForJob();

      // Should still have just 1 application (no duplicate).
      expect(apps.applications.length, 1);
    });

    test('job returns JobDetailModel from source', () {
      registerSavedJobs();
      registerApplications();

      final c = JobDetailController(source: sampleJob);
      final j = c.job;

      expect(j?.title, 'Flutter Developer');
      expect(j?.companyName, 'Acme Corp');
      expect(j?.category, 'Senior');
    });

    test('jobId matches source id', () {
      registerSavedJobs();
      registerApplications();

      final c = JobDetailController(source: sampleJob);
      expect(c.jobId, 'job-1');
    });
  });
}
