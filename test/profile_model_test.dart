import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';

void main() {
  group('ProfileModel', () {
    const sample = ProfileModel(
      name: 'Jumnert',
      role: 'CSE Student',
      coverImageUrl: 'https://example.com/cover.jpg',
      avatarImageUrl: 'https://example.com/avatar.jpg',
      about: 'I build apps.',
      experiences: [
        ExperienceModel(
          company: 'Acme',
          title: 'Dev',
          duration: '2 Years',
          description: 'Worked on things.',
          logoImageUrl: 'https://example.com/logo.png',
        ),
      ],
      skills: ['Flutter', 'Dart', 'Firebase'],
      portfolioLinks: [
        PortfolioLink(title: 'GitHub', url: 'https://github.com/j'),
      ],
    );

    test('toJson/fromJson round-trip preserves all fields', () {
      final json = sample.toJson();
      final restored = ProfileModel.fromJson(json);

      expect(restored.name, sample.name);
      expect(restored.role, sample.role);
      expect(restored.coverImageUrl, sample.coverImageUrl);
      expect(restored.avatarImageUrl, sample.avatarImageUrl);
      expect(restored.about, sample.about);
      expect(restored.experiences.length, 1);
      expect(restored.experiences.first.company, 'Acme');
      expect(restored.skills, sample.skills);
      expect(restored.portfolioLinks.length, 1);
      expect(restored.portfolioLinks.first.title, 'GitHub');
      expect(restored.avatarBytes, isNull);
      expect(restored.coverBytes, isNull);
    });

    test('copyWith creates correct copy changing selected fields', () {
      final copy = sample.copyWith(name: 'NewName', role: 'Senior Dev');

      expect(copy.name, 'NewName');
      expect(copy.role, 'Senior Dev');
      // Unchanged fields remain the same.
      expect(copy.about, sample.about);
      expect(copy.skills, sample.skills);
      expect(copy.experiences, sample.experiences);
      expect(copy.portfolioLinks, sample.portfolioLinks);
    });

    test('copyWith preserves bytes when not overridden', () {
      final withBytes = ProfileModel(
        name: sample.name,
        role: sample.role,
        coverImageUrl: sample.coverImageUrl,
        avatarImageUrl: sample.avatarImageUrl,
        about: sample.about,
        experiences: sample.experiences,
        skills: sample.skills,
        portfolioLinks: sample.portfolioLinks,
        avatarBytes: Uint8List.fromList([1, 2, 3]),
        coverBytes: Uint8List.fromList([4, 5, 6]),
      );

      final copy = withBytes.copyWith(name: 'New');

      expect(copy.avatarBytes, isNotNull);
      expect(copy.coverBytes, isNotNull);
    });

    test('copyWith clearAvatar removes avatar bytes', () {
      final withBytes = sample.copyWith(
        avatarBytes: Uint8List.fromList([1, 2, 3]),
      );
      final cleared = withBytes.copyWith(clearAvatar: true);

      expect(cleared.avatarBytes, isNull);
      expect(cleared.hasAvatarBytes, isFalse);
    });

    test('copyWith clearCover removes cover bytes', () {
      final withBytes = sample.copyWith(
        coverBytes: Uint8List.fromList([4, 5, 6]),
      );
      final cleared = withBytes.copyWith(clearCover: true);

      expect(cleared.coverBytes, isNull);
      expect(cleared.hasCoverBytes, isFalse);
    });

    test('hasAvatarBytes returns true when bytes are non-empty', () {
      final withAvatar = sample.copyWith(
        avatarBytes: Uint8List.fromList([1, 2]),
      );

      expect(withAvatar.hasAvatarBytes, isTrue);
    });

    test('hasCoverBytes returns false when no cover bytes', () {
      expect(sample.hasCoverBytes, isFalse);
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = ProfileModel.fromJson(<String, dynamic>{});

      expect(restored.name, '');
      expect(restored.role, '');
      expect(restored.about, '');
      expect(restored.experiences, isEmpty);
      expect(restored.skills, isEmpty);
      expect(restored.portfolioLinks, isEmpty);
    });
  });

  group('ExperienceModel', () {
    test('toJson/fromJson round-trip', () {
      const exp = ExperienceModel(
        company: 'Acme',
        title: 'Dev',
        duration: '2 Years',
        description: 'Worked.',
        logoImageUrl: 'https://example.com/logo.png',
      );

      final json = exp.toJson();
      final restored = ExperienceModel.fromJson(json);

      expect(restored.company, exp.company);
      expect(restored.title, exp.title);
      expect(restored.duration, exp.duration);
      expect(restored.description, exp.description);
      expect(restored.logoImageUrl, exp.logoImageUrl);
    });

    test('copyWith clearLogo removes logo URL', () {
      const exp = ExperienceModel(
        company: 'Acme',
        title: 'Dev',
        duration: '1 Year',
        description: 'Done.',
        logoImageUrl: 'https://example.com/logo.png',
      );

      final cleared = exp.copyWith(clearLogo: true);

      expect(cleared.logoImageUrl, isNull);
    });

    test('toJson omits logoImageUrl when null', () {
      const exp = ExperienceModel(
        company: 'Acme',
        title: 'Dev',
        duration: '1 Year',
        description: 'Done.',
      );

      final json = exp.toJson();

      expect(json.containsKey('logoImageUrl'), isFalse);
    });
  });

  group('PortfolioLink', () {
    test('toJson/fromJson round-trip', () {
      const link = PortfolioLink(title: 'GitHub', url: 'https://github.com/j');

      final json = link.toJson();
      final restored = PortfolioLink.fromJson(json);

      expect(restored.title, link.title);
      expect(restored.url, link.url);
    });

    test('copyWith works', () {
      const link = PortfolioLink(title: 'GitHub', url: 'https://github.com/j');

      final copy = link.copyWith(url: 'https://github.com/new');

      expect(copy.title, 'GitHub');
      expect(copy.url, 'https://github.com/new');
    });
  });
}
