import 'job_application.dart';
import 'result.dart';
abstract class ApplicationRepository {
  Future<Result<List<JobApplication>>> fetchAll(); 
  Future<Result<JobApplication>> fetchById(int id); 
  Future<Result<JobApplication>> create(JobApplication draft); 
  Future<Result<JobApplication>> update(JobApplication application); 
  Future<Result<void>> delete(int id); 
}