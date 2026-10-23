import 'package:flutter/foundation.dart';
import '../data/job_post.dart';
import '../data/job_post_repository.dart';
import '../data/result.dart';

class JobsModel extends ChangeNotifier {
  JobsModel(this._repository);

  final JobPostRepository _repository;

  static const techFilters = ['Flutter', 'Java', 'Python', 'React', 'QA', 'DevOps'];
  static const scheduleFilters = ['Part-time', 'Стажировка', 'Remote'];

  bool _loading = false;
  String? _error;
  List<JobPost> _jobs = const [];

  String _query = '';
  final Set<String> _tech = {};
  final Set<String> _schedule = {};

  bool get isLoading => _loading;
  String? get error => _error;
  List<JobPost> get jobs => List.unmodifiable(_jobs);

  String get query => _query;
  bool isTechSelected(String label) => _tech.contains(label);
  bool isScheduleSelected(String label) => _schedule.contains(label);
  bool get hasFilters =>
      _query.isNotEmpty || _tech.isNotEmpty || _schedule.isNotEmpty;

  List<JobPost> get visibleJobs => List.unmodifiable(
        _jobs.where((j) => _matchesQuery(j) && _matchesTech(j) && _matchesSchedule(j)),
      );

  JobPost? byId(int id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); 

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _jobs = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners(); 
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void toggleTech(String label) {
    if (!_tech.remove(label)) _tech.add(label);
    notifyListeners();
  }

  void toggleSchedule(String label) {
    if (!_schedule.remove(label)) _schedule.add(label);
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _tech.clear();
    _schedule.clear();
    notifyListeners();
  }

  bool _matchesQuery(JobPost j) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return j.title.toLowerCase().contains(q) ||
        j.company.toLowerCase().contains(q) ||
        j.techStack.any((t) => t.toLowerCase().contains(q));
  }

  bool _matchesTech(JobPost j) {
    if (_tech.isEmpty) return true;
    final haystack = '${j.title} ${j.techStack.join(' ')}'.toLowerCase();
    return _tech.any((t) => haystack.contains(t.toLowerCase()));
  }

  bool _matchesSchedule(JobPost j) {
    if (_schedule.isEmpty) return true;
    return _schedule.any(
      (s) => s == 'Remote' ? j.location.contains('Remote') : j.schedule.contains(s),
    );
  }
}