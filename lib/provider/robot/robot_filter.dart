import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/robot.dart';

class RobotFilterProvider extends ChangeNotifier {
  // Các field cần lọc
  String _nameQuery = "";
  // Getter
  String get nameQuery => _nameQuery;
  // Setter
  void setNameContains(String query) {
    if (_nameQuery == query) return;
    _nameQuery = query;
    notifyListeners();
  }

  // Clear
  void clear() {
    _nameQuery = "";
    notifyListeners();
  }

  List<Robot> apply(List<Robot> source) {
    return source.where((robot) {
      if (_nameQuery == "") {
        return true;
      }
      return robot.name.toLowerCase().contains(_nameQuery.toLowerCase());
    }).toList();
  }
}
