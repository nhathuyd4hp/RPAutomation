import 'dart:convert';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:task_distribution/data/model/api_response.dart';
import 'package:task_distribution/data/model/run_error.dart';
import 'package:task_distribution/data/model/run.dart';

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

    final apiResponse = APIResponse<List<Run>>.fromJson(
      responseJson,
      (data) => (data as List<dynamic>)
          .map((item) => Run.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<RError?> getError(String id) async {
    final url = Uri.parse("$backend/api/runs/$id/error");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);

    final apiResponse = APIResponse<RError>.fromJson(
      responseJson,
      (data) => RError.fromJson(data as Map<String, dynamic>),
    );
    return apiResponse.data;
  }

  Future<bool> download({required Run run, required String savePath}) async {
    if (run.result == null) return false;
    final String result = run.result!;
    final String filePath = p.join(savePath, p.basename(result));
    final List<String> parts = result.split('/');
    final String urlString =
        "$backend/api/assets/${parts[0]}?objectName=${parts.sublist(1).join("/")}";
    return await Isolate.run<bool>(() async {
      final client = http.Client();
      try {
        final response = await client.send(
          http.Request('GET', Uri.parse(urlString)),
        );
        if (response.statusCode != 200) return false;
        final file = File(filePath);
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        await sink.close();
        return true;
      } catch (e) {
        return false;
      } finally {
        client.close();
      }
    });
  }

  Future<bool> stop(Run run) async {
    final url = Uri.parse("$backend/api/runs/${run.id}/stop");
    final response = await http.post(url);
    return response.statusCode == 200;
  }
}
