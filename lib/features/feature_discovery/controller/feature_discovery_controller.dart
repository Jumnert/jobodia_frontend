import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';

class FeatureInfo {
  const FeatureInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
}

class FeatureDiscoveryController extends GetxController {
  final _storage = GetStorage();
  final RxMap<String, bool> discoveredFeatures = <String, bool>{}.obs;
  final RxBool hasSeenWalkthrough = false.obs;

  static const features = [
    FeatureInfo(
      id: 'aiChat',
      title: 'AI Chat',
      description: 'Get instant career advice from our AI assistant.',
      icon: Icons.smart_toy_rounded,
      route: AppRoutes.aiChat,
    ),
    FeatureInfo(
      id: 'cvBuilder',
      title: 'CV Builder',
      description: 'Build a professional CV in minutes.',
      icon: Icons.description_rounded,
      route: AppRoutes.cvBuilder,
    ),
    FeatureInfo(
      id: 'flashcards',
      title: 'Interview Flashcards',
      description: 'Practice for your interviews with flashcards.',
      icon: Icons.style_rounded,
      route: AppRoutes.flashcards,
    ),
    FeatureInfo(
      id: 'assessments',
      title: 'Skill Assessments',
      description: 'Test your skills and earn badges.',
      icon: Icons.quiz_rounded,
      route: AppRoutes.assessments,
    ),
    FeatureInfo(
      id: 'marketTrends',
      title: 'Market Trends',
      description: 'See what skills are in demand.',
      icon: Icons.insights_rounded,
      route: AppRoutes.marketTrends,
    ),
    FeatureInfo(
      id: 'careerGoals',
      title: 'Career Goals',
      description: 'Set and track your career progression.',
      icon: Icons.trending_up_rounded,
      route: AppRoutes.careerGoals,
    ),
    FeatureInfo(
      id: 'jobAlerts',
      title: 'Job Alerts',
      description: 'Get notified for matching jobs.',
      icon: Icons.notifications_active_rounded,
      route: AppRoutes.notifications,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadState();
  }

  void _loadState() {
    hasSeenWalkthrough.value =
        _storage.read<bool>('hasSeenWalkthrough') ?? false;
    final map = _storage.read<Map<String, dynamic>>('discoveredFeatures') ?? {};
    discoveredFeatures.assignAll(map.map((k, v) => MapEntry(k, v as bool)));
  }

  bool isDiscovered(String featureId) {
    return discoveredFeatures[featureId] ?? false;
  }

  void markDiscovered(String featureId) {
    discoveredFeatures[featureId] = true;
    _storage.write('discoveredFeatures', discoveredFeatures);
  }

  void resetDiscovery() {
    discoveredFeatures.clear();
    hasSeenWalkthrough.value = false;
    _storage.remove('discoveredFeatures');
    _storage.remove('hasSeenWalkthrough');
  }

  int undiscoveredCount() {
    return features.where((f) => !isDiscovered(f.id)).length;
  }

  void markWalkthroughSeen() {
    hasSeenWalkthrough.value = true;
    _storage.write('hasSeenWalkthrough', true);
  }
}
