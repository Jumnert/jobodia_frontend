import 'dart:convert';
import 'dart:typed_data';

class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.role,
    required this.coverImageUrl,
    required this.avatarImageUrl,
    required this.about,
    required this.experiences,
    this.skills = const [],
    this.portfolioLinks = const [],
    this.avatarBytes,
    this.coverBytes,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final avatarB64 = json['avatarBytes'] as String?;
    final coverB64 = json['coverBytes'] as String?;
    return ProfileModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      avatarImageUrl: json['avatarImageUrl'] as String? ?? '',
      about: json['about'] as String? ?? '',
      experiences:
          (json['experiences'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ExperienceModel.fromJson)
              .toList() ??
          const [],
      skills:
          (json['skills'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      portfolioLinks:
          (json['portfolioLinks'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PortfolioLink.fromJson)
              .toList() ??
          const [],
      avatarBytes: (avatarB64 == null || avatarB64.isEmpty)
          ? null
          : base64Decode(avatarB64),
      coverBytes: (coverB64 == null || coverB64.isEmpty)
          ? null
          : base64Decode(coverB64),
    );
  }

  final String name;
  final String role;
  final String coverImageUrl;
  final String avatarImageUrl;
  final String about;
  final List<ExperienceModel> experiences;
  final List<String> skills;
  final List<PortfolioLink> portfolioLinks;

  /// Locally-picked avatar image bytes. Null when using the URL fallback.
  final Uint8List? avatarBytes;

  /// Locally-picked cover image bytes. Null when using the URL fallback.
  final Uint8List? coverBytes;

  bool get hasAvatarBytes => avatarBytes != null && avatarBytes!.isNotEmpty;
  bool get hasCoverBytes => coverBytes != null && coverBytes!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'coverImageUrl': coverImageUrl,
    'avatarImageUrl': avatarImageUrl,
    'about': about,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'skills': skills,
    'portfolioLinks': portfolioLinks.map((p) => p.toJson()).toList(),
    if (avatarBytes != null && avatarBytes!.isNotEmpty)
      'avatarBytes': base64Encode(avatarBytes!),
    if (coverBytes != null && coverBytes!.isNotEmpty)
      'coverBytes': base64Encode(coverBytes!),
  };

  ProfileModel copyWith({
    String? name,
    String? role,
    String? coverImageUrl,
    String? avatarImageUrl,
    String? about,
    List<ExperienceModel>? experiences,
    List<String>? skills,
    List<PortfolioLink>? portfolioLinks,
    Uint8List? avatarBytes,
    Uint8List? coverBytes,
    bool clearAvatar = false,
    bool clearCover = false,
  }) => ProfileModel(
    name: name ?? this.name,
    role: role ?? this.role,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    avatarImageUrl: avatarImageUrl ?? this.avatarImageUrl,
    about: about ?? this.about,
    experiences: experiences ?? this.experiences,
    skills: skills ?? this.skills,
    portfolioLinks: portfolioLinks ?? this.portfolioLinks,
    avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
    coverBytes: clearCover ? null : (coverBytes ?? this.coverBytes),
  );
}

class ExperienceModel {
  const ExperienceModel({
    required this.company,
    required this.title,
    required this.duration,
    required this.description,
    this.logoImageUrl,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      ExperienceModel(
        company: json['company'] as String? ?? '',
        title: json['title'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        description: json['description'] as String? ?? '',
        logoImageUrl: json['logoImageUrl'] as String?,
      );

  final String company;
  final String title;
  final String duration;
  final String description;
  final String? logoImageUrl;

  Map<String, dynamic> toJson() => {
    'company': company,
    'title': title,
    'duration': duration,
    'description': description,
    if (logoImageUrl != null) 'logoImageUrl': logoImageUrl,
  };

  ExperienceModel copyWith({
    String? company,
    String? title,
    String? duration,
    String? description,
    String? logoImageUrl,
    bool clearLogo = false,
  }) => ExperienceModel(
    company: company ?? this.company,
    title: title ?? this.title,
    duration: duration ?? this.duration,
    description: description ?? this.description,
    logoImageUrl: clearLogo ? null : (logoImageUrl ?? this.logoImageUrl),
  );
}

class PortfolioLink {
  const PortfolioLink({required this.title, required this.url});

  factory PortfolioLink.fromJson(Map<String, dynamic> json) => PortfolioLink(
    title: json['title'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );

  final String title;
  final String url;

  Map<String, dynamic> toJson() => {'title': title, 'url': url};

  PortfolioLink copyWith({String? title, String? url}) =>
      PortfolioLink(title: title ?? this.title, url: url ?? this.url);
}
