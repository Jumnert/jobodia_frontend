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

  String get headline => switch (this) {
    UserRole.jobSeeker => "I'm here to find work",
    UserRole.employer => "I'm here to hire",
  };

  String get description => switch (this) {
    UserRole.jobSeeker =>
      'Discover roles that match your skills and track your applications.',
    UserRole.employer =>
      'Post openings, review candidates, and manage your hiring.',
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
