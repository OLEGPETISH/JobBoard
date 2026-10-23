import 'package:flutter/foundation.dart';
import '../data/application_repository.dart';
import '../data/job_application.dart';
import '../data/result.dart';

class ApplicationsModel extends ChangeNotifier {
  ApplicationsModel(this._repository);

  final ApplicationRepository _repository;

  bool _loading = false;
  String? _error;
  List<JobApplication> _applications = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<JobApplication> get applications => List.unmodifiable(_applications);

  JobApplication? byId(int id) {
    for (final a in _applications) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _applications = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }

  Future<String?> add(JobApplication draft) async {
    switch (await _repository.create(draft)) {
      case Ok(:final value):
        _applications = [value, ..._applications]; 
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg; 
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _applications = _applications.where((a) => a.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}