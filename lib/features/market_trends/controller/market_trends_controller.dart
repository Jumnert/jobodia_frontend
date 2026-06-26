import 'package:get/get.dart';
import 'package:jobodia_frontend/features/market_trends/model/market_trend_model.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';

class MarketTrendsController extends GetxController {
  final trends = <MarketTrendModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
  }

  void _seedData() {
    trends.assignAll([
      MarketTrendModel(
        category: 'industry',
        name: 'FinTech',
        demandScore: 95,
        changePercent: 12.5,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'industry',
        name: 'HealthTech',
        demandScore: 88,
        changePercent: 8.2,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'industry',
        name: 'E-commerce',
        demandScore: 82,
        changePercent: 2.1,
        trend: 'stable',
      ),
      MarketTrendModel(
        category: 'industry',
        name: 'EdTech',
        demandScore: 70,
        changePercent: -3.5,
        trend: 'declining',
      ),
      MarketTrendModel(
        category: 'industry',
        name: 'Crypto',
        demandScore: 65,
        changePercent: -15.0,
        trend: 'declining',
      ),

      MarketTrendModel(
        category: 'skill',
        name: 'Flutter',
        demandScore: 92,
        changePercent: 18.0,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'React',
        demandScore: 89,
        changePercent: 5.0,
        trend: 'stable',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Python',
        demandScore: 85,
        changePercent: 4.2,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'UI/UX Design',
        demandScore: 78,
        changePercent: 2.5,
        trend: 'stable',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Java',
        demandScore: 75,
        changePercent: -2.0,
        trend: 'declining',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Swift',
        demandScore: 72,
        changePercent: 1.5,
        trend: 'stable',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Kotlin',
        demandScore: 70,
        changePercent: 6.0,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Docker',
        demandScore: 65,
        changePercent: 10.0,
        trend: 'rising',
      ),
      MarketTrendModel(
        category: 'skill',
        name: 'Ruby',
        demandScore: 50,
        changePercent: -8.0,
        trend: 'declining',
      ),
    ]);
  }

  List<MarketTrendModel> topIndustries() {
    final list = trends.where((t) => t.category == 'industry').toList()
      ..sort((a, b) => b.demandScore.compareTo(a.demandScore));
    return list.take(5).toList();
  }

  List<MarketTrendModel> topSkills() {
    final list = trends.where((t) => t.category == 'skill').toList()
      ..sort((a, b) => b.demandScore.compareTo(a.demandScore));
    return list;
  }

  int userMarketFit() {
    if (!Get.isRegistered<ProfileController>()) return 0;
    final profileCtrl = Get.find<ProfileController>();
    final userSkills = profileCtrl.profile.skills
        .map((s) => s.toLowerCase())
        .toSet();
    if (userSkills.isEmpty) return 0;

    final topSkillNames = topSkills()
        .take(5)
        .map((s) => s.name.toLowerCase())
        .toSet();
    final matchCount = topSkillNames.intersection(userSkills).length;

    return (matchCount / topSkillNames.length * 100).toInt();
  }
}
