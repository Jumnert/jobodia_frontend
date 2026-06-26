class MarketTrendModel {
  MarketTrendModel({
    required this.category,
    required this.name,
    required this.demandScore,
    required this.changePercent,
    required this.trend,
  });

  final String category; // industry / skill / location
  final String name;
  final int demandScore;
  final double changePercent;
  final String trend; // rising / stable / declining

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name': name,
      'demandScore': demandScore,
      'changePercent': changePercent,
      'trend': trend,
    };
  }

  factory MarketTrendModel.fromJson(Map<String, dynamic> json) {
    return MarketTrendModel(
      category: json['category'] as String,
      name: json['name'] as String,
      demandScore: json['demandScore'] as int,
      changePercent: (json['changePercent'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}
