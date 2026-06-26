import 'package:get/get.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

/// Manages ephemeral job comparison state on the Saved Jobs screen.
/// Holds up to 3 selected jobs for side-by-side comparison. No persistence.
class ComparisonController extends GetxController {
  static const maxSelection = 3;

  /// Whether comparison mode is currently active.
  final RxBool isActive = false.obs;

  /// Selected job ids, in selection order.
  final RxList<String> selectedIds = <String>[].obs;

  bool get hasSelection => selectedIds.isNotEmpty;
  int get selectionCount => selectedIds.length;
  bool get isFull => selectedIds.length >= maxSelection;

  bool isSelected(String id) => selectedIds.contains(id);

  /// Toggles a job in the comparison set. If the set is full and the job is
  /// not already selected, does nothing.
  void toggle(JobFeedModel job) {
    if (selectedIds.remove(job.id)) return;
    if (isFull) return;
    selectedIds.add(job.id);
  }

  void clear() {
    selectedIds.clear();
    isActive.value = false;
  }

  /// Toggle comparison mode on/off.
  void toggleActive() {
    isActive.toggle();
    if (!isActive.value) {
      selectedIds.clear();
    }
  }

  /// Builds a comparison table from the selected jobs and the full job list.
  List<JobFeedModel> selectedJobs(List<JobFeedModel> allJobs) {
    return selectedIds
        .map((id) => allJobs.firstWhereOrNull((j) => j.id == id))
        .whereType<JobFeedModel>()
        .toList();
  }
}
