import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/company/model/company_model.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

class CompanyController extends GetxController {
  static const _followKey = 'followedCompanies';
  final _storage = GetStorage();
  final followedCompanies = <String>{}.obs;

  final companies = <CompanyModel>[
    const CompanyModel(
      name: 'NovaTech',
      industry: 'Technology',
      headcount: '500-1000',
      about:
          'NovaTech builds next-generation AI-powered productivity tools for modern teams.',
      tag: 'NovaTech',
    ),
    const CompanyModel(
      name: 'FinVerse',
      industry: 'Fintech',
      headcount: '200-500',
      about:
          'FinVerse is a leading fintech startup revolutionizing digital banking in Southeast Asia.',
      tag: 'FinVerse',
    ),
    const CompanyModel(
      name: 'GovTech',
      industry: 'Government Technology',
      headcount: '1000+',
      about: 'GovTech is the agency for digital transformation in government.',
      tag: 'GovTech',
    ),
    const CompanyModel(
      name: 'Metro Digital',
      industry: 'Digital Agency',
      headcount: '50-200',
      about:
          'Metro Digital is a creative digital agency specializing in web and mobile experiences.',
      tag: 'Metro',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<List>(_followKey);
    if (stored != null) {
      followedCompanies.addAll(stored.cast<String>());
    }
  }

  bool isFollowing(String name) => followedCompanies.contains(name);

  void toggleFollow(String name) {
    if (followedCompanies.contains(name)) {
      followedCompanies.remove(name);
    } else {
      followedCompanies.add(name);
    }
    followedCompanies.refresh();
    _storage.write(_followKey, followedCompanies.toList());
  }

  int get followingCount => followedCompanies.length;

  CompanyModel? companyByName(String name) =>
      companies.firstWhereOrNull((c) => c.name == name);

  /// Returns jobs from [allJobs] whose company name contains the company's
  /// [tag] (case-insensitive), or whose [company] field contains the
  /// company [name].
  List<JobFeedModel> jobsForCompany(
    CompanyModel company,
    List<JobFeedModel> allJobs,
  ) {
    final nameLower = company.name.toLowerCase();
    final tagLower = (company.tag ?? '').toLowerCase();
    return allJobs.where((job) {
      final companyLower = job.company.toLowerCase();
      return companyLower.contains(nameLower) ||
          companyLower.contains(tagLower);
    }).toList();
  }
}
