import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/run.dart';

class RunFilterProvider extends ChangeNotifier {
  // Các field cần lọc
  String _nameQuery = "";
  String? _statusQuery;
  bool _isAscending = false;
  // Getter
  String get nameQuery => _nameQuery;
  String? get statusQuery => _statusQuery;
  bool get isAscending => _isAscending;
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

  void setIsAscending() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  // Clear
  void clear() {
    _nameQuery = "";
    _statusQuery = "";
    _isAscending = true;
    notifyListeners();
  }

  List<Run> apply(List<Run> source) {
    final filtered = source.where((run) {
      final nameOk =
          _nameQuery.isEmpty ||
          run.robot.toLowerCase().contains(_nameQuery.toLowerCase());

      final statusOk =
          _statusQuery == null ||
          run.status.toLowerCase().contains(_statusQuery!.toLowerCase());

      return nameOk && statusOk;
    }).toList();

    filtered.sort((a, b) {
      if (_isAscending) {
        return a.createdAt.compareTo(b.createdAt);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }
}
