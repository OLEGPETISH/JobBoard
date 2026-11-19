import 'api_client.dart';
import 'application_repository.dart';
import 'job_application.dart';
import 'result.dart';

class HttpApplicationRepository implements ApplicationRepository {
  HttpApplicationRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<JobApplication>>> fetchAll() => _api.call(
        'GET',
        '/applications',
        parse: (json) {
          final data = json as Map<String, dynamic>;
          return (data['items'] as List)
              .map((e) => JobApplication.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  @override
  Future<Result<JobApplication>> fetchById(int id) => _api.call(
        'GET',
        '/applications/$id',
        parse: (json) => JobApplication.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<JobApplication>> create(JobApplication draft) => _api.call(
        'POST',
        '/applications',
        body: draft.toJson(),
        okStatus: 201,
        parse: (json) => JobApplication.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<JobApplication>> update(JobApplication application) => _api.call(
        'PUT',
        '/applications/${application.id}',
        body: application.toJson(),
        parse: (json) => JobApplication.fromJson(json as Map<String, dynamic>),
      );

  @override
  Future<Result<void>> delete(int id) => _api.call(
        'DELETE',
        '/applications/$id',
        okStatus: 204,
        parse: (_) {},
      );
}