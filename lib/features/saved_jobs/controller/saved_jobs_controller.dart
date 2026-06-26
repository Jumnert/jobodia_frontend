import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

/// Tracks which jobs the seeker has saved (favorited).
///
/// Persists a plain JSON list of job ids via [GetStorage] so favorites survive
/// app restarts. Keeping the stored shape to ids only means a real API can
/// replace this storage layer later without any UI change.
class SavedJobsController extends GetxController {
  SavedJobsController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const savedJobIdsKey = 'savedJobIds';

  final GetStorage _storage;

  /// Reactive set of saved job ids the UI observes to keep hearts in sync.
  final RxSet<String> savedIds = <String>{}.obs;

  /// Cached reversed list, invalidated whenever [savedIds] changes.
  List<String>? _cachedOrderedIds;

  @override
  void onInit() {
    super.onInit();
    savedIds.addAll(_readStoredIds());
    ever(savedIds, (_) => _cachedOrderedIds = null);
  }

  /// Saved ids in most-recently-saved-first order.
  ///
  /// Result is cached and only rebuilt when [savedIds] changes.
  List<String> get orderedSavedIds =>
      _cachedOrderedIds ??= savedIds.toList().reversed.toList();

  bool isSaved(String id) => savedIds.contains(id);

  void toggleSave(JobFeedModel job) {
    if (savedIds.contains(job.id)) {
      savedIds.remove(job.id);
    } else {
      savedIds.add(job.id);
    }
    _cachedOrderedIds = null;
    _persist();
  }

  void remove(String id) {
    if (savedIds.remove(id)) {
      _cachedOrderedIds = null;
      _persist();
    }
  }

  void _persist() {
    _storage.write(savedJobIdsKey, savedIds.toList());
  }

  List<String> _readStoredIds() {
    try {
      final raw = _storage.read<dynamic>(savedJobIdsKey);
      if (raw is List) {
        return raw.whereType<String>().toList();
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load saved job IDs from storage', e, st);
    }
    return <String>[];
  }
}
