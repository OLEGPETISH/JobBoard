import 'job_post.dart';
import 'result.dart';

abstract class JobPostRepository {
  Future<Result<List<JobPost>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  });  Future<Result<JobPost>> fetchById(int id); 
  Future<Result<JobPost>> create(JobPost post); 
  Future<Result<JobPost>> update(JobPost post); 
  Future<Result<void>> delete(int id); 
}