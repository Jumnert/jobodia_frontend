class SalaryInsightModel {
  const SalaryInsightModel({
    required this.role,
    required this.minSalary,
    required this.maxSalary,
    required this.medianSalary,
    required this.demandLevel,
    required this.userExpectedSalary,
  });

  final String role;
  final double minSalary;
  final double maxSalary;
  final double medianSalary;
  final SalaryDemand demandLevel;
  final double userExpectedSalary;
}

enum SalaryDemand { low, medium, high }
