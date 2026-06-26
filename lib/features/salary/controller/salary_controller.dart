import 'package:get/get.dart';
import 'package:jobodia_frontend/features/salary/model/salary_insight_model.dart';

class SalaryController extends GetxController {
  final Rx<SalaryInsightModel?> insight = Rx<SalaryInsightModel?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInsight();
  }

  Future<void> _fetchInsight() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    insight.value = const SalaryInsightModel(
      role: 'Flutter Developer',
      minSalary: 60000,
      maxSalary: 150000,
      medianSalary: 110000,
      demandLevel: SalaryDemand.high,
      userExpectedSalary: 95000,
    );
    isLoading.value = false;
  }
}
