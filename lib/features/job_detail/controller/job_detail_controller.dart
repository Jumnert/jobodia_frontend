import 'package:get/get.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/job_detail/model/job_detail_model.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/apply_confirmation_dialog.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:share_plus/share_plus.dart';

class JobDetailController extends GetxController {
  JobDetailController({
    JobFeedModel? source,
    SavedJobsController? savedJobs,
    ApplicationsController? applications,
  }) : _source =
           source ??
           (Get.arguments is JobFeedModel
               ? Get.arguments as JobFeedModel
               : null),
       _savedJobs = savedJobs ?? Get.find<SavedJobsController>(),
       _applications = applications ?? Get.find<ApplicationsController>() {
    if (_source == null) {
      jobNotFound.value = true;
    }
  }

  final JobFeedModel? _source;
  final SavedJobsController _savedJobs;
  final ApplicationsController _applications;

  final RxBool isAboutRoleExpanded = false.obs;
  final RxBool jobNotFound = false.obs;

  /// Holds a non-null error message when the last apply attempt failed.
  final RxnString applyError = RxnString();

  /// The id of the job being viewed, used to read/write saved + applied state.
  String get jobId => _source?.id ?? '';

  /// Reactive saved state sourced from the shared [SavedJobsController] so the
  /// detail screen stays in sync with the feed and saved-jobs list.
  bool get isSaved => _savedJobs.isSaved(jobId);

  /// Reactive applied state sourced from the shared [ApplicationsController].
  bool get isApplied => _applications.hasApplied(jobId);

  JobDetailModel? get job {
    final source = _source;
    if (source == null) return null;
    return JobDetailModel(
      title: source.title,
      companyName: source.company,
      postedDate: source.timeAgo,
      workMode: source.location,
      category: source.level,
      department: source.tags.isNotEmpty ? source.tags.first : 'General',
      heroImageUrl:
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=85',
      description: source.description,
      aboutRole: '',
      moreJobs: const [],
    );
  }

  // --- Source fields for display-only widgets (salary bar, match sheet) ---

  /// Salary string from the feed model, e.g. "\$3,500 - \$5,200".
  String get sourceSalary => _source?.salary ?? '';

  /// Match percentage (0–100) from the feed model.
  int get matchPercent => _source?.matchPercent ?? 0;

  /// Skill tags from the feed model.
  List<String> get sourceTags => _source?.tags ?? const [];

  /// Location from the feed model (used for location match dimension).
  String get sourceLocation => _source?.location ?? '';

  /// Experience level from the feed model (used for experience match dimension).
  String get sourceLevel => _source?.level ?? '';

  void toggleSaved() {
    _savedJobs.toggleSave(_source!);
  }

  void toggleAboutRole() {
    isAboutRoleExpanded.toggle();
  }

  void shareJob() {
    final j = job;
    SharePlus.instance.share(
      ShareParams(
        text:
            '${j?.title ?? ''} at ${j?.companyName ?? ''}\nhttps://jobodia.app/jobs/${_source!.id}',
      ),
    );
  }

  Future<void> applyForJob() async {
    if (isApplied) {
      return;
    }
    applyError.value = null;
    try {
      // Dialog returns null on Cancel, empty/non-empty string on Confirm.
      final coverLetter = await Get.dialog<String?>(
        ApplyConfirmationDialog(
          jobTitle: job?.title ?? '',
          companyName: job?.companyName ?? '',
        ),
        barrierDismissible: false,
      );

      if (coverLetter == null) {
        // User cancelled.
        return;
      }

      _recordApplication(coverLetter.isEmpty ? null : coverLetter);
      Get.snackbar('Application sent', 'Your application has been submitted.');
    } on Exception {
      applyError.value = 'Failed to submit application. Please try again.';
    }
  }

  /// Clears [applyError] so the UI hides the error state.
  void clearApplyError() => applyError.value = null;

  void _recordApplication(String? coverLetter) {
    _applications.apply(_source!, coverLetter: coverLetter);
  }
}
