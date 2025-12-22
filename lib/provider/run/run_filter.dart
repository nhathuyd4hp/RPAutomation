import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/run.dart';

class RunFilterProvider extends ChangeNotifier {
  // Các field cần lọc
  String _nameQuery = "";
  String? _statusQuery;
  // Getter
  String get nameQuery => _nameQuery;
  String? get statusQuery => _statusQuery;
  // Setter
  void setNameContains(String query) {
    if (_nameQuery == query) return;
    _nameQuery = query;
    notifyListeners();
  }

  void setStatus(String? query) {
    if (_statusQuery == query) return;
    _statusQuery = query;
    notifyListeners();
  }

  // Clear
  void clear() {
    _nameQuery = "";
    _statusQuery = "";
    notifyListeners();
  }

  List<Run> apply(List<Run> source) {
    return source.where((run) {
      final nameOk =
          _nameQuery == "" ||
          run.robot.toLowerCase().contains(_nameQuery.toLowerCase());

      final statusOk =
          _statusQuery == null ||
          run.status.toLowerCase().contains(_statusQuery!.toLowerCase());

      return nameOk && statusOk;
    }).toList();
  }
}
