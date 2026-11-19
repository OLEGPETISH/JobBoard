import 'package:flutter/foundation.dart';
import '../data/job_post.dart';
import '../data/job_post_repository.dart';
import '../data/result.dart';

class JobsModel extends ChangeNotifier {
  JobsModel(this._repository);

  final JobPostRepository _repository;

  static const techFilters = ['Flutter', 'Java', 'Python', 'React', 'QA', 'DevOps'];
  static const scheduleFilters = ['Part-time', 'Стажировка', 'Remote'];
  static const _limit = 20;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  int _generation = 0; // растёт при каждой новой загрузке с нуля
  String? _error;
  String? _moreError;
  List<JobPost> _jobs = const [];

  String _query = ''; // уходит на сервер как ?search=
  final Set<String> _tech = {};
  final Set<String> _schedule = {};

  bool get isLoading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get moreError => _moreError;
  List<JobPost> get jobs => List.unmodifiable(_jobs);

  String get query => _query;
  bool isTechSelected(String label) => _tech.contains(label);
  bool isScheduleSelected(String label) => _schedule.contains(label);
  bool get hasFilters =>
      _query.isNotEmpty || _tech.isNotEmpty || _schedule.isNotEmpty;

  // Текст уже отфильтровал сервер; здесь только клиентские чипы.
  List<JobPost> get visibleJobs => List.unmodifiable(
        _jobs.where((j) => _matchesTech(j) && _matchesSchedule(j)),
      );

  JobPost? byId(int id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  /// Первая страница с нуля. Использует текущий _query, поэтому
  /// «Повторить» после ошибки не теряет поиск.
  Future<void> load() async {
    final gen = ++_generation;
    _loading = true;
    _loadingMore = false;
    _error = null;
    _moreError = null;
    _page = 1;
    notifyListeners();

    final result =
        await _repository.fetchAll(page: 1, limit: _limit, search: _query);
    if (gen != _generation) return; // пока ждали, началась более новая загрузка

    switch (result) {
      case Ok(:final value):
        _jobs = value;
        _hasMore = value.length == _limit; // неполная страница = конец
      case Err(:final msg):
        _error = msg;
        _hasMore = false;
    }

    _loading = false;
    notifyListeners();
  }

  /// Поиск на сервере: запоминаем строку и грузим первую страницу заново.
  Future<void> search(String value) {
    _query = value.trim();
    return load();
  }

  /// Следующая страница. Вызывается из itemBuilder, поэтому до await
  /// notifyListeners() нельзя: это был бы setState во время build.
  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    _loadingMore = true;
    _moreError = null;
    final gen = _generation;
    final next = _page + 1;

    final result =
        await _repository.fetchAll(page: next, limit: _limit, search: _query);
    if (gen != _generation) return; // поиск сменился, ответ устарел

    switch (result) {
      case Ok(:final value):
        _jobs = [..._jobs, ...value];
        _page = next;
        _hasMore = value.length == _limit;
      case Err(:final msg):
        _moreError = msg; // список остаётся, в хвосте появится «повторить»
    }

    _loadingMore = false;
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
    final hadQuery = _query.isNotEmpty;
    _query = '';
    _tech.clear();
    _schedule.clear();
    if (hadQuery) {
      load(); // строка поиска была на сервере, значит, перезагружаем
    } else {
      notifyListeners();
    }
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