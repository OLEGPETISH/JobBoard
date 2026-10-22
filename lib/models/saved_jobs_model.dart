import 'package:flutter/foundation.dart';

class SavedJobsModel extends ChangeNotifier {
  final Set<int> _ids = {}; 

  List<int> get ids => List.unmodifiable(_ids); 
  int get count => _ids.length;

  bool isSaved(int jobId) => _ids.contains(jobId);

  void toggle(int jobId) {
    if (!_ids.remove(jobId)) _ids.add(jobId);
    notifyListeners();
  }
}