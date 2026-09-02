import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/services/api_client.dart';

/// Live job-feed API. The endpoint is public; users may browse listings before
/// signing in and no job data is cached on the device.
class JobsApi {
  JobsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<JobsPage> list({int page = 0, int size = 20}) async {
    final payload = await _client.get(
      '/api/v1/jobs?page=$page&size=$size',
      requiresAuth: false,
    );
    if (payload is! Map) {
      throw const ApiException('The server returned an invalid job list.');
    }
    final json = Map<String, dynamic>.from(payload);
    final content = json['content'];
    if (content is! List) {
      throw const ApiException('The server returned an invalid job list.');
    }
    return JobsPage(
      jobs: content
          .whereType<Map>()
          .map(
            (item) => JobFeedModel.fromApiJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      last: json['last'] == true,
    );
  }
}

class JobsPage {
  const JobsPage({required this.jobs, required this.last});

  final List<JobFeedModel> jobs;
  final bool last;
}
