class ReferralModel {
  const ReferralModel({
    required this.id,
    required this.friendName,
    required this.status,
    required this.dateInvited,
    this.rewardEarned = 0.0,
  });

  final String id;
  final String friendName;
  final ReferralStatus status;
  final DateTime dateInvited;
  final double rewardEarned;

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      friendName: json['friendName'] as String,
      status: ReferralStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReferralStatus.invited,
      ),
      dateInvited: DateTime.parse(json['dateInvited'] as String),
      rewardEarned: (json['rewardEarned'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'friendName': friendName,
    'status': status.name,
    'dateInvited': dateInvited.toIso8601String(),
    'rewardEarned': rewardEarned,
  };
}

enum ReferralStatus { invited, registered, hired }
