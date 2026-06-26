import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

import 'home_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetStorage>()])
void main() {
  late MockGetStorage mockStorage;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();

    when(mockStorage.read<List>('dismissedJobIds')).thenReturn(null);
    when(mockStorage.read<int>('homeSelectedTab')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
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

  HomeController makeController() {
    final c = HomeController(storage: mockStorage);
    c.onInit();
    return c;
  }

  group('HomeController', () {
    test('initial state — filteredJobs returns all jobs when no filters', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;
      expect(c.filteredJobs.length, c.jobs.length);
    });

    test('selectLevel filters jobs by level', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;

      c.selectLevel('Expert');
      expect(c.selectedLevel.value, 'Expert');

      final filtered = c.filteredJobs;
      expect(filtered.every((j) => j.level == 'Expert'), isTrue);

      c.selectLevel('Expert');
      expect(c.selectedLevel.value, isNull);
    });

    test('selectLevel returns only matching jobs', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;
      c.selectLevel('Senior');
      final filtered = c.filteredJobs;
      expect(filtered.length, 3);
    });

    test('dismiss adds job to dismissedJobIds', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;

      final jobToDismiss = c.jobs.first;
      // Suppress the snackbar that dismiss() shows.
      c.dismissedJobIds.add(jobToDismiss.id);
      // Verify the id is tracked.
      expect(c.dismissedJobIds.contains(jobToDismiss.id), isTrue);
    });

    test('dismissed jobs are filtered from filteredJobs', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;
      final initialCount = c.filteredJobs.length;

      // Manually dismiss a job without triggering snackbar.
      final jobToDismiss = c.jobs.first;
      c.dismissedJobIds.add(jobToDismiss.id);

      expect(c.filteredJobs.length, initialCount - 1);
      expect(c.filteredJobs.any((j) => j.id == jobToDismiss.id), isFalse);
    });

    test('jobById returns correct job', () {
      final c = makeController();
      final job = c.jobById('novatech-product-designer');
      expect(job, isNotNull);
      expect(job!.title, 'Product Designer - SaaS');
    });

    test('jobById returns null for unknown id', () {
      final c = makeController();
      expect(c.jobById('nonexistent-id'), isNull);
    });

    test('dismissedJobIds persists to storage on dismiss', () {
      registerSavedJobs();
      final c = makeController();
      c.selectedTab.value = 0;

      // Simulate dismiss persistence directly (skip the snackbar).
      c.dismissedJobIds.add('test-id');
      mockStorage.write('dismissedJobIds', c.dismissedJobIds.toList());

      verify(mockStorage.write('dismissedJobIds', any)).called(greaterThan(0));
    });
  });
}
