import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/referrals/model/referral_model.dart';
import 'package:uuid/uuid.dart';

class ReferralController extends GetxController {
  final _uuid = const Uuid();

  final String referralCode = 'JOBODIA-WIN-2026';
  final double totalEarned = 150.0;

  late final RxList<ReferralModel> referrals;

  @override
  void onInit() {
    super.onInit();
    referrals = _mockReferrals().obs;
  }

  void copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode));
    Get.snackbar(
      'Copied!',
      'Referral code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareReferralLink() {
    // In a real app, use share_plus package
    Get.snackbar(
      'Shared!',
      'Link shared successfully (mock)',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  List<ReferralModel> _mockReferrals() => [
    ReferralModel(
      id: _uuid.v4(),
      friendName: 'Alex Johnson',
      status: ReferralStatus.hired,
      dateInvited: DateTime.now().subtract(const Duration(days: 45)),
      rewardEarned: 100.0,
    ),
    ReferralModel(
      id: _uuid.v4(),
      friendName: 'Sarah Smith',
      status: ReferralStatus.hired,
      dateInvited: DateTime.now().subtract(const Duration(days: 30)),
      rewardEarned: 50.0,
    ),
    ReferralModel(
      id: _uuid.v4(),
      friendName: 'Mike Brown',
      status: ReferralStatus.registered,
      dateInvited: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReferralModel(
      id: _uuid.v4(),
      friendName: 'Emily Davis',
      status: ReferralStatus.invited,
      dateInvited: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
