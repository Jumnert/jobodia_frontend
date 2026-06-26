import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';

void main() {
  group('ApplicationStatus', () {
    test('all enum values exist', () {
      expect(ApplicationStatus.values, hasLength(5));
      expect(ApplicationStatus.values, contains(ApplicationStatus.applied));
      expect(ApplicationStatus.values, contains(ApplicationStatus.phoneScreen));
      expect(ApplicationStatus.values, contains(ApplicationStatus.interview));
      expect(ApplicationStatus.values, contains(ApplicationStatus.offer));
      expect(ApplicationStatus.values, contains(ApplicationStatus.rejected));
    });

    test('wireName maps to correct snake_case strings', () {
      expect(ApplicationStatus.applied.wireName, 'applied');
      expect(ApplicationStatus.phoneScreen.wireName, 'phone_screen');
      expect(ApplicationStatus.interview.wireName, 'interview');
      expect(ApplicationStatus.offer.wireName, 'offer');
      expect(ApplicationStatus.rejected.wireName, 'rejected');
    });

    test('fromWire parses valid strings', () {
      expect(ApplicationStatus.fromWire('applied'), ApplicationStatus.applied);
      expect(
        ApplicationStatus.fromWire('phone_screen'),
        ApplicationStatus.phoneScreen,
      );
      expect(
        ApplicationStatus.fromWire('interview'),
        ApplicationStatus.interview,
      );
      expect(ApplicationStatus.fromWire('offer'), ApplicationStatus.offer);
      expect(
        ApplicationStatus.fromWire('rejected'),
        ApplicationStatus.rejected,
      );
    });

    test('fromWire defaults to applied for unknown/null strings', () {
      expect(ApplicationStatus.fromWire('bogus'), ApplicationStatus.applied);
      expect(ApplicationStatus.fromWire(null), ApplicationStatus.applied);
      expect(ApplicationStatus.fromWire(''), ApplicationStatus.applied);
    });

    test('fromWire round-trips with wireName', () {
      for (final status in ApplicationStatus.values) {
        expect(
          ApplicationStatus.fromWire(status.wireName),
          status,
          reason: 'Round-trip failed for $status',
        );
      }
    });
  });

  group('JobApplication', () {
    final sample = JobApplication(
      jobId: 'job-123',
      appliedDate: DateTime(2025, 6, 15),
      coverLetter: 'I am interested.',
      status: 'applied',
    );

    test('toJson preserves all fields', () {
      final json = sample.toJson();

      expect(json['jobId'], 'job-123');
      expect(json['appliedDate'], '2025-06-15T00:00:00.000');
      expect(json['coverLetter'], 'I am interested.');
      expect(json['status'], 'applied');
    });

    test('fromJson restores all fields', () {
      final json = sample.toJson();
      final restored = JobApplication.fromJson(json);

      expect(restored.jobId, sample.jobId);
      expect(restored.appliedDate, sample.appliedDate);
      expect(restored.coverLetter, sample.coverLetter);
      expect(restored.status, sample.status);
    });

    test('toJson omits coverLetter when null or empty', () {
      final noLetter = JobApplication(
        jobId: 'job-456',
        appliedDate: DateTime(2025, 1, 1),
      );

      final json = noLetter.toJson();

      expect(json.containsKey('coverLetter'), isFalse);
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = JobApplication.fromJson(<String, dynamic>{});

      expect(restored.jobId, '');
      expect(restored.coverLetter, isNull);
      expect(restored.status, 'applied');
      // appliedDate falls back to DateTime.now() on unparseable input.
      expect(restored.appliedDate, isA<DateTime>());
    });

    test('fromJson handles invalid status gracefully', () {
      final json = sample.toJson();
      json['status'] = 'invalid_status';

      final restored = JobApplication.fromJson(json);

      // The raw status string is preserved in the field.
      expect(restored.status, 'invalid_status');
      // statusEnum falls back to `applied` for unrecognized strings.
      expect(restored.statusEnum, ApplicationStatus.applied);
    });

    test('statusEnum returns correct typed value', () {
      final phoneScreen = sample.copyWith(status: 'phone_screen');
      final interview = sample.copyWith(status: 'interview');

      expect(phoneScreen.statusEnum, ApplicationStatus.phoneScreen);
      expect(interview.statusEnum, ApplicationStatus.interview);
    });
  });
}

/// Extension to allow copyWith for tests -- the model doesn't have one.
extension on JobApplication {
  JobApplication copyWith({
    String? jobId,
    DateTime? appliedDate,
    String? coverLetter,
    String? status,
  }) => JobApplication(
    jobId: jobId ?? this.jobId,
    appliedDate: appliedDate ?? this.appliedDate,
    coverLetter: coverLetter ?? this.coverLetter,
    status: status ?? this.status,
  );
}
