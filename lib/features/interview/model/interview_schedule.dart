class InterviewSchedule {
  InterviewSchedule({
    required this.jobId,
    required this.dateTime,
    this.notes = '',
  });
  final String jobId;
  final DateTime dateTime;
  final String notes;

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'dateTime': dateTime.toIso8601String(),
    'notes': notes,
  };
  factory InterviewSchedule.fromJson(Map<String, dynamic> json) =>
      InterviewSchedule(
        jobId: json['jobId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        notes: json['notes'] as String? ?? '',
      );
}
