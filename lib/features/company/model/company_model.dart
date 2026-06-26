class CompanyModel {
  const CompanyModel({
    required this.name,
    required this.industry,
    required this.headcount,
    required this.about,
    this.tag,
  });
  final String name;
  final String industry;
  final String headcount;
  final String about;
  final String? tag;
}
