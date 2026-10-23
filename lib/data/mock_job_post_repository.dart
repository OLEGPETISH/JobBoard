import 'job_post.dart';
import 'job_post_repository.dart';
import 'mock_data.dart';
import 'result.dart';

class MockJobPostRepository implements JobPostRepository {
  final List<JobPost> _posts = List.of(mockJobs); 
  int _nextId = 1000; 
  bool simulateError = false; 

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Вакансия не существует';


  Future<String?> _network() async {
    await Future.delayed(_latency);
    return simulateError ? _errNetwork : null;
  }

  @override
  Future<Result<List<JobPost>>> fetchAll() async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    return Ok(List.of(_posts)); 
  }

  @override
  Future<Result<JobPost>> fetchById(int id) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _posts.indexWhere((p) => p.id == id);
    if (i == -1) return const Err(_errNotFound); 
    return Ok(_posts[i]);
  }

  @override
  Future<Result<JobPost>> create(JobPost post) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final created = post.copyWith(id: _nextId++); 
    _posts.add(created);
    return Ok(created);
  }

  @override
  Future<Result<JobPost>> update(JobPost post) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i == -1) return const Err(_errNotFound);
    _posts[i] = post;
    return Ok(post);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _posts.indexWhere((p) => p.id == id);
    if (i == -1) return const Err(_errNotFound);
    _posts.removeAt(i);
    return const Ok(null); 
}
}