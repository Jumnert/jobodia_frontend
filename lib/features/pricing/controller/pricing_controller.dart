import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PricingController extends GetxController {
  PricingController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _planKey = 'selectedPricingPlan';
  static const _cycleKey = 'pricingBillingCycle';

  final GetStorage _storage;

  /// Currently active plan name (Starter, Pro, Career Plus). Defaults to Starter.
  late final RxString activePlan =
      (_storage.read<String>(_planKey) ?? 'Starter').obs;

  /// Currently active billing cycle ('monthly' or 'yearly').
  late final RxString activeCycle =
      (_storage.read<String>(_cycleKey) ?? 'monthly').obs;

  bool isCurrentPlan(String planName) => activePlan.value == planName;

  void selectPlan(String planName, String cycle) {
    activePlan.value = planName;
    activeCycle.value = cycle;
    _storage.write(_planKey, planName);
    _storage.write(_cycleKey, cycle);
  }
}
