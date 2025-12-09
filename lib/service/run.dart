import 'dart:convert';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:task_distribution/model/run.dart';

class RunClient {
  final String backend;

  RunClient(this.backend);

  Future<List<Run>> getRuns() async {
    final url = Uri.parse("$backend/api/runs");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    final data = responseJson['data'];
    final List<Run> runs = data
        .map<Run>((e) => Run.fromJson(e as Map<String, dynamic>))
        .toList();
    return runs;
  }

  Future<(bool, String)> getResult({
    required Run run,
    required String savePath,
  }) async {
    try {
      final url = Uri.parse("$backend/api/runs/result/${run.id}");
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return (false, "Không tìm thấy file kết quả");
      }
      final file = File(p.join(savePath, p.basename(run.result!)));
      await file.writeAsBytes(response.bodyBytes);
      return (true, file.toString());
    } catch (e) {
      return (false, e.toString());
    }
  }
}
