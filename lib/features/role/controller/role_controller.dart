import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// The account persona chosen after sign up.
enum UserRole { jobSeeker, employer }

extension UserRoleX on UserRole {
  String get storageValue => name;

  String get label => switch (this) {
    UserRole.jobSeeker => 'Job Seeker',
    UserRole.employer => 'Employer',
  };

  String get labelKey => switch (this) {
    UserRole.jobSeeker => 'role_job_seeker_label',
    UserRole.employer => 'role_employer_label',
  };

  String get headline => switch (this) {
    UserRole.jobSeeker => "I'm here to find work",
    UserRole.employer => "I'm here to hire",
  };

  String get headlineKey => switch (this) {
    UserRole.jobSeeker => 'role_job_seeker_headline',
    UserRole.employer => 'role_employer_headline',
  };

  String get description => switch (this) {
    UserRole.jobSeeker => 'Find matching jobs and track applications.',
    UserRole.employer => 'Post jobs and manage candidates.',
  };

  String get descriptionKey => switch (this) {
    UserRole.jobSeeker => 'role_job_seeker_description',
    UserRole.employer => 'role_employer_description',
  };
}

/// Stores the selected [UserRole] and persists it across launches.
class RoleController extends GetxController {
  RoleController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const storageKey = 'userRole';

  final GetStorage _storage;
  final Rxn<UserRole> role = Rxn<UserRole>();

  bool get hasRole => role.value != null;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<String>(storageKey);
    if (stored != null) {
      for (final value in UserRole.values) {
        if (value.storageValue == stored) {
          role.value = value;
          break;
        }
      }
    }
  }

  void selectRole(UserRole value) {
    role.value = value;
    _storage.write(storageKey, value.storageValue);
  }
}
