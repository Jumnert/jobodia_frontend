import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/services/api_client.dart';

/// Saved jobs are account data held by the backend. The set below is only the
/// current screen state; it is refreshed from the API on every app launch.
class SavedJobsController extends GetxController {
  SavedJobsController({ApiClient? apiClient, GetStorage? storage})
    : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  final RxSet<String> savedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;

  List<String>? _cachedOrderedIds;

  @override
  void onInit() {
    super.onInit();
    ever(savedIds, (_) => _cachedOrderedIds = null);
    unawaited(load());
  }

  List<String> get orderedSavedIds =>
      _cachedOrderedIds ??= savedIds.toList().reversed.toList();

  bool isSaved(String id) => savedIds.contains(id);

  Future<void> load() async {
    isLoading.value = true;
    try {
      final payload = await _api.get('/api/v1/saved-jobs');
      if (payload is! Map || payload['content'] is! List) return;
      savedIds.assignAll(
        (payload['content'] as List)
            .whereType<Map>()
            .map((item) => item['jobId']?.toString())
            .whereType<String>(),
      );
    } on ApiException catch (error) {
      // Browsing jobs is allowed without sign-in. In that state there are no
      // account favourites to display.
      if (error.statusCode != 401) rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSave(JobFeedModel job) async {
    if (savedIds.contains(job.id)) {
      await _api.delete('/api/v1/saved-jobs/${job.id}');
      savedIds.remove(job.id);
    } else {
      await _api.post('/api/v1/saved-jobs/${job.id}');
      savedIds.add(job.id);
    }
  }

  Future<void> remove(String id) async {
    if (!savedIds.contains(id)) return;
    await _api.delete('/api/v1/saved-jobs/$id');
    savedIds.remove(id);
  }
}
