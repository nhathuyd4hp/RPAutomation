import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import "../model/robot.dart";

class RobotProvider extends ChangeNotifier {
  List<Robot> _robots = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Setter
  List<Robot> get robots => _robots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // ----------------------------------------------------
  // KHỞI TẠO STATE
  // ----------------------------------------------------
  RobotProvider() {
    _initState();
  }
  Future<void> _initState() async {
    await initState();
  }

  // ----------------------------------------------------
  // CALL API
  // ----------------------------------------------------
  Future<dynamic> initState() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = Uri.parse('http://localhost:8000/api/robots');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _robots = [
          Robot(
            name: "src.robot.DrawingClassic.tasks.drawing_classic",
            active: true,
            parameters: [],
          ),
          Robot(
            name: "src.robot.ShigaToyoChiba.tasks.shiga_toyo_chiba",
            active: true,
            parameters: [
              Parameters(
                name: "process_date",
                required: true,
                annotation: "datetime.date | str",
                defaultValue: null,
              ),
            ],
          ),
        ];
      }
    } catch (e) {
      _robots = [];
      _errorMessage = '$e';
      Future.delayed(const Duration(seconds: 5), () {
        initState();
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
