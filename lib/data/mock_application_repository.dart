import 'application_repository.dart';
import 'job_application.dart';
import 'mock_data.dart';
import 'result.dart';

class MockApplicationRepository implements ApplicationRepository {
  final List<JobApplication> _applications = List.of(mockApplications); 
  int _nextId = 1000;
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Отклик не существует';
  static const _months = [
    'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июн.',
    'июл.', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.',
  ];

  Future<String?> _network() async {
    await Future.delayed(_latency);
    return simulateError ? _errNetwork : null;
  }

  String _today() {
    final d = DateTime.now();
    return '${d.day} ${_months[d.month - 1]}';
  }

  @override
  Future<Result<List<JobApplication>>> fetchAll() async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    return Ok(List.of(_applications));
  }

  @override
  Future<Result<JobApplication>> fetchById(int id) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _applications.indexWhere((a) => a.id == id);
    if (i == -1) return const Err(_errNotFound);
    return Ok(_applications[i]);
  }

  @override
  Future<Result<JobApplication>> create(JobApplication draft) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final created = draft.copyWith(
      id: _nextId++, 
      sentDate: _today(), 
      status: ApplicationStatus.sent, 
    );
    _applications.insert(0, created); 
    return Ok(created);
  }

  @override
  Future<Result<JobApplication>> update(JobApplication application) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _applications.indexWhere((a) => a.id == application.id);
    if (i == -1) return const Err(_errNotFound);
    _applications[i] = application;
    return Ok(application);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final fail = await _network();
    if (fail != null) return Err(fail);
    final i = _applications.indexWhere((a) => a.id == id);
    if (i == -1) return const Err(_errNotFound);
    _applications.removeAt(i);
    return const Ok(null);
  }
}