import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';
import 'package:share_plus/share_plus.dart';

class ProfileController extends GetxController {
  ProfileController({GetStorage? storage, ImagePicker? picker})
    : _storage = storage ?? GetStorage(),
      _picker = picker ?? ImagePicker();

  static const _profileKey = 'profile';

  final GetStorage _storage;
  final ImagePicker _picker;

  final RxBool isAboutExpanded = false.obs;
  final RxBool isSaved = false.obs;
  final RxnString saveError = RxnString();

  late final Rx<ProfileModel> profileRx;

  static const _mockProfile = ProfileModel(
    name: 'Jumnert',
    role: 'Cse Student',
    coverImageUrl:
        'https://images.unsplash.com/photo-1616469829941-c7200edec809?w=800',
    avatarImageUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
    about:
        'A Frontend Developer is responsible for building the user-facing side of web applications, ensuring that websites and apps are visually appealing, responsive, and easy to use. They collaborate with designers and backend developers to deliver seamless digital products.',
    skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX Design', 'Git', 'REST APIs'],
    portfolioLinks: [
      PortfolioLink(title: 'GitHub', url: 'https://github.com/jumnert'),
      PortfolioLink(
        title: 'Behance Portfolio',
        url: 'https://behance.net/jumnert',
      ),
      PortfolioLink(title: 'Personal Website', url: 'https://jumnert.dev'),
    ],
    experiences: [
      ExperienceModel(
        company: 'Department of Homeland Security',
        title: 'Product Manager',
        duration: '1 Years',
        logoImageUrl: null,
        description:
            'A Frontend Developer is responsible for building the user-facing side of web applications.',
      ),
      ExperienceModel(
        company: 'Acme Corp',
        title: 'Senior Product Designer',
        duration: '1 Years',
        logoImageUrl: null,
        description:
            'A Frontend Developer is responsible for building the user-facing side of web applications, A Frontend Developer is responsible for building the user-facing side of web applications,',
      ),
      ExperienceModel(
        company: 'ABA Bank',
        title: 'Business Analyst',
        duration: '1 Years',
        logoImageUrl: null,
        description:
            'A Frontend Developer is responsible for building the user-facing side of web applications,',
      ),
      ExperienceModel(
        company: 'Jobodia',
        title: 'Frontend Developer',
        duration: '2 Years',
        description:
            'Built responsive mobile interfaces, reusable components, and product screens for hiring workflows.',
      ),
      ExperienceModel(
        company: 'Swift Bank',
        title: 'UI Designer',
        duration: '8 Months',
        description:
            'Designed account screens, dashboard cards, and clean onboarding flows for mobile users.',
      ),
      ExperienceModel(
        company: 'Freelance',
        title: 'Mobile App Developer',
        duration: '1 Years',
        description:
            'Delivered Flutter screens, fixed layout bugs, and connected app views with backend APIs.',
      ),
    ],
  );

  ProfileModel get profile => profileRx.value;

  @override
  void onInit() {
    super.onInit();
    profileRx = _load().obs;
  }

  ProfileModel _load() {
    // Secure storage is async; use GetStorage as fallback for sync onInit.
    // Profile will be migrated to secure storage on next save.
    try {
      final stored = _storage.read<Map>(_profileKey);
      if (stored != null) {
        return ProfileModel.fromJson(Map<String, dynamic>.from(stored));
      }
    } on Object {
      // Fall through to mock on any parse error.
    }
    return _mockProfile;
  }

  /// Saves an updated profile and notifies listeners.
  /// Writes to both secure storage (PII) and GetStorage (sync fallback).
  void updateProfile(ProfileModel updated) {
    saveError.value = null;
    try {
      profileRx.value = updated;
      _storage.write(_profileKey, updated.toJson());
      SecureStorageService.to.writeSecure(
        _profileKey,
        jsonEncode(updated.toJson()),
      );
    } on Exception {
      saveError.value = 'Failed to save profile. Please try again.';
    }
  }

  void clearSaveError() => saveError.value = null;

  void toggleAbout() {
    isAboutExpanded.toggle();
  }

  void toggleSaved() {
    isSaved.toggle();
  }

  void shareProfile() {
    final p = profile;
    final slug = p.name.toLowerCase().replaceAll(' ', '');
    SharePlus.instance.share(
      ShareParams(
        text: '${p.name} — ${p.role}\nhttps://jobodia.app/profile/$slug',
      ),
    );
  }

  /// Opens the gallery picker and stores the selected image.
  /// [isAvatar] controls whether the avatar or cover is updated.
  Future<void> _pickImage({required bool isAvatar}) async {
    final bytes = await _pickImageBytes();
    if (bytes != null) {
      updateProfile(
        isAvatar
            ? profile.copyWith(avatarBytes: bytes)
            : profile.copyWith(coverBytes: bytes),
      );
    }
  }

  Future<void> pickAvatar() => _pickImage(isAvatar: true);
  Future<void> pickCover() => _pickImage(isAvatar: false);

  void removeAvatar() {
    updateProfile(profile.copyWith(clearAvatar: true));
  }

  void removeCover() {
    updateProfile(profile.copyWith(clearCover: true));
  }

  Future<Uint8List?> _pickImageBytes() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return picked.readAsBytes();
    } on Object {
      Get.snackbar(
        'Photo unavailable',
        'Could not access your photos. Check photo permissions and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }
  }
}
