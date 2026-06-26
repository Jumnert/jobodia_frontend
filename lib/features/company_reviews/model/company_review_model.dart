class CompanyReviewModel {
  CompanyReviewModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.reviewerName,
    required this.rating,
    required this.title,
    required this.pros,
    required this.cons,
    required this.advice,
    required this.isCurrentEmployee,
    required this.jobTitle,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String reviewerName;
  final int rating;
  final String title;
  final String pros;
  final String cons;
  final String advice;
  final bool isCurrentEmployee;
  final String jobTitle;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'reviewerName': reviewerName,
      'rating': rating,
      'title': title,
      'pros': pros,
      'cons': cons,
      'advice': advice,
      'isCurrentEmployee': isCurrentEmployee,
      'jobTitle': jobTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CompanyReviewModel.fromJson(Map<String, dynamic> json) {
    return CompanyReviewModel(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      reviewerName: json['reviewerName'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String,
      pros: json['pros'] as String,
      cons: json['cons'] as String,
      advice: json['advice'] as String,
      isCurrentEmployee: json['isCurrentEmployee'] as bool,
      jobTitle: json['jobTitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
