/// A reusable professional message template for job seekers.
class RecruiterMessage {
  const RecruiterMessage({
    required this.title,
    required this.category,
    required this.body,
  });

  final String title;
  final String category;
  final String body;

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'body': body,
  };

  factory RecruiterMessage.fromJson(Map<String, dynamic> json) =>
      RecruiterMessage(
        title: json['title'] as String,
        category: json['category'] as String,
        body: json['body'] as String,
      );
}
