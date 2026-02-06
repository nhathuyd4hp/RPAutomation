import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:task_distribution/data/model/run.dart';
import 'package:task_distribution/data/model/run_error.dart';
import 'package:task_distribution/providers/socket.dart';
import 'package:task_distribution/data/services/run.dart';

class RunProvider extends ChangeNotifier {
  //
  // Properties
  final Map<String, bool> _downloading = {};
  Map<String, bool> get downloading => _downloading;
  //
  final RunClient repository;
  final ServerProvider server;
  List<Run> _runs = [];
  // Getter
  List<Run> get runs => _runs;
  // Constructor
  RunProvider({required this.repository, required this.server});
  // bindServer
  Future<void> bindServer() async {
    if (server.status == ConnectionStatus.connected) {
      _runs = await repository.getRuns();
    } else {
      _runs = [];
    }
    notifyListeners();
  }

  Future<void> download(Run run) async {
    if (run.status != "SUCCESS" || run.result == null || run.result == "") {
      return server.error("Không tìm thấy file kết quả");
    }
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Save ${p.basename(run.result!)}",
    );
    if (directoryPath == null) return;
    try {
      _downloading[run.id] = true;
      notifyListeners();
      final success = await repository.download(
        run: run,
        savePath: directoryPath,
      );
      if (success) {
        server.info(
          "Lưu thành công",
          actions: {
            "Mở thư mục": () async {
              await OpenFile.open(directoryPath);
            },
            "Xem kết quả": () async {
              final filePath = p.join(directoryPath, p.basename(run.result!));

              await OpenFile.open(filePath);
            },
          },
        );
      } else {
        server.info("Tải file thất bại");
      }
    } catch (e) {
      server.error("Lỗi: $e");
    } finally {
      _downloading[run.id] = false;
      notifyListeners();
    }
  }

  Future<void> stop(Run run) async {
    final bool success = await repository.stop(run);
    if (!success) {
      return server.error("Yêu cầu dừng ${run.robot} thất bại");
    }
    server.info("Đã gửi yêu cầu dừng ${run.robot}");
  }

  Future<RError?> getError(String id) async {
    return await repository.getError(id);
  }
}
