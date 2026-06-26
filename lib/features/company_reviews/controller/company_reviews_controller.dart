import 'package:get/get.dart';
import 'package:jobodia_frontend/features/company_reviews/model/company_review_model.dart';
import 'package:uuid/uuid.dart';

class CompanyReviewsController extends GetxController {
  final _uuid = const Uuid();
  final RxList<CompanyReviewModel> reviews = <CompanyReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedMockData();
  }

  void _seedMockData() {
    reviews.addAll([
      CompanyReviewModel(
        id: 'r1',
        companyId: 'c1',
        companyName: 'Google',
        reviewerName: 'John Doe',
        rating: 5,
        title: 'Great place to work',
        pros: 'Amazing perks, smart people, good work-life balance.',
        cons: 'Can be slow to launch products.',
        advice: 'Keep doing what you are doing.',
        isCurrentEmployee: true,
        jobTitle: 'Senior Software Engineer',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CompanyReviewModel(
        id: 'r2',
        companyId: 'c1',
        companyName: 'Google',
        reviewerName: 'Jane Smith',
        rating: 4,
        title: 'Good benefits but huge codebase',
        pros: 'Great pay, free food.',
        cons: 'Hard to make an impact.',
        advice: 'More cross-team collaboration needed.',
        isCurrentEmployee: false,
        jobTitle: 'Product Manager',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ]);
  }

  List<CompanyReviewModel> reviewsForCompany(String companyName) {
    return reviews
        .where((r) => r.companyName.toLowerCase() == companyName.toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  double averageRating(String companyName) {
    final compReviews = reviewsForCompany(companyName);
    if (compReviews.isEmpty) return 0.0;
    final sum = compReviews.fold(0, (prev, curr) => prev + curr.rating);
    return sum / compReviews.length;
  }

  void submitReview({
    required String companyName,
    required String reviewerName,
    required int rating,
    required String title,
    required String pros,
    required String cons,
    required String advice,
    required bool isCurrentEmployee,
    required String jobTitle,
  }) {
    final newReview = CompanyReviewModel(
      id: _uuid.v4(),
      companyId: 'c_auto',
      companyName: companyName,
      reviewerName: reviewerName,
      rating: rating,
      title: title,
      pros: pros,
      cons: cons,
      advice: advice,
      isCurrentEmployee: isCurrentEmployee,
      jobTitle: jobTitle,
      createdAt: DateTime.now(),
    );
    reviews.insert(0, newReview);

    Get.back(); // close modal
    Get.snackbar('Review Submitted', 'Thanks for your feedback!');
  }
}
