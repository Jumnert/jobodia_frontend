import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';

/// Maps an existing user profile onto CV builder field names.
///
/// Pure mapping only: it reads the profile and returns a plain map keyed the
/// same way [ResumeParserService] results are keyed. No side effects, no
/// storage, no GetX state changes.
class AutoFillService {
  /// Builds a field map from the current profile held by [profile].
  ///
  /// Maps profile name → fullName, role → title, about → summary,
  /// skills → skills, and the first experience → a single work entry.
  Map<String, dynamic> fillFromProfile(ProfileController profile) {
    final model = profile.profile;
    final fields = <String, dynamic>{};

    if (model.name.trim().isNotEmpty) {
      fields['fullName'] = model.name.trim();
    }
    if (model.role.trim().isNotEmpty) {
      fields['title'] = model.role.trim();
    }
    if (model.about.trim().isNotEmpty) {
      fields['summary'] = model.about.trim();
    }
    if (model.skills.isNotEmpty) {
      fields['skills'] = List<String>.from(model.skills);
    }

    if (model.experiences.isNotEmpty) {
      final first = model.experiences.first;
      if (first.company.trim().isNotEmpty) {
        fields['company'] = first.company.trim();
      }
      if (first.title.trim().isNotEmpty) {
        fields['role'] = first.title.trim();
      }
      if (first.description.trim().isNotEmpty) {
        fields['workDesc'] = first.description.trim();
      }
    }

    return fields;
  }
}
