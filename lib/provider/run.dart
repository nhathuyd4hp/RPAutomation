import 'package:flutter/foundation.dart';
import 'package:task_distribution/model/run.dart';
import 'package:task_distribution/provider/socket.dart';
import 'package:task_distribution/service/run.dart';

class RunProvider extends ChangeNotifier {
  //
  final RunClient repository;
  List<Run> _runs = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Getter
  List<Run> get runs => _runs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Constructor
  RunProvider(this.repository);
  // bindServer
  Future<void> bindServer(ServerProvider server) async {
    if (server.status == ConnectionStatus.connecting) {
      _isLoading = true;
      _runs = [];
    }
    if (server.status == ConnectionStatus.connected) {
      _isLoading = false;
      _errorMessage = null;
      _runs = await repository.getRuns();
    }
    if (server.status == ConnectionStatus.disconnected) {
      _isLoading = false;
      _errorMessage = server.errorMessage;
      _runs = [];
    }
    notifyListeners();
  }
}
