/// Pipeline stages for a job application.
enum ApplicationStatus {
  applied,
  phoneScreen,
  interview,
  offer,
  rejected;

  /// Backing wire name used for JSON persistence.
  String get wireName => switch (this) {
    ApplicationStatus.applied => 'applied',
    ApplicationStatus.phoneScreen => 'phone_screen',
    ApplicationStatus.interview => 'interview',
    ApplicationStatus.offer => 'offer',
    ApplicationStatus.rejected => 'rejected',
  };

  static ApplicationStatus fromWire(String? value) => switch (value) {
    'phone_screen' => ApplicationStatus.phoneScreen,
    'interview' => ApplicationStatus.interview,
    'offer' => ApplicationStatus.offer,
    'rejected' => ApplicationStatus.rejected,
    _ => ApplicationStatus.applied,
  };
}

/// A single job application record: the job id plus when it was applied.
///
/// Stored as a simple JSON map so the persistence layer stays
/// forward-compatible — a real API can return the same shape later.
class JobApplication {
  const JobApplication({
    required this.jobId,
    required this.appliedDate,
    this.coverLetter,
    this.status = 'applied',
  });

  final String jobId;
  final DateTime appliedDate;
  final String? coverLetter;

  /// Pipeline status: 'applied', 'phone_screen', 'interview', 'offer', 'rejected'.
  final String status;

  /// Typed status accessor.
  ApplicationStatus get statusEnum => ApplicationStatus.fromWire(status);

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'appliedDate': appliedDate.toIso8601String(),
    if (coverLetter != null && coverLetter!.isNotEmpty)
      'coverLetter': coverLetter,
    'status': status,
  };

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
    jobId: json['jobId'] as String? ?? '',
    appliedDate:
        DateTime.tryParse(json['appliedDate'] as String? ?? '') ??
        DateTime.now(),
    coverLetter: json['coverLetter'] as String?,
    status: (json['status'] as String?) ?? 'applied',
  );
}
