import 'api_client.dart';
import 'job_post.dart';
import 'job_post_repository.dart';
import 'result.dart';

class HttpJobPostRepository implements JobPostRepository {
  HttpJobPostRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<JobPost>>> fetchAll() => _api.call(
        'GET',
        '/job-posts',
        parse: (json) {
          final data = json as Map<String, dynamic>; // конверт {items, page, ...}
          return (data['items'] as List)
              .map((e) => JobPost.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  @override
  Future<Result<JobPost>> fetchById(int id) => _api.call(
        'GET',
        '/job-posts/$id',
        parse: (json) => JobPost.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<JobPost>> create(JobPost post) => _api.call(
        'POST',
        '/job-posts',
        body: post.toJson(),
        okStatus: 201,
        parse: (json) => JobPost.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<JobPost>> update(JobPost post) => _api.call(
        'PUT',
        '/job-posts/${post.id}',
        body: post.toJson(),
        parse: (json) => JobPost.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<void>> delete(int id) => _api.call(
        'DELETE',
        '/job-posts/$id',
        okStatus: 204,
        parse: (_) {}, 
      );
}