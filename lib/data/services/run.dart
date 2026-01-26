import 'dart:convert';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:task_distribution/data/model/api_response.dart';
import 'package:task_distribution/data/model/run_error.dart';
import 'package:task_distribution/data/model/run.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final List<String> parts = run.result!.split('/');
    final String bucket = parts[0];
    final String objectName = parts.sublist(1).join("/");
    // Call API
    final url = Uri.parse("$backend/api/assets/$bucket?objectName=$objectName");
    final String filePath = p.join(savePath, p.basename(run.result!));
    final file = File(filePath);
    try {
      final client = http.Client();
      final request = http.Request('GET', url);
      final response = await client.send(request);
      if (response.statusCode != 200) {
        client.close();
        return false;
      }
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      await sink.close();
      client.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> stop(Run run) async {
    final url = Uri.parse("$backend/api/runs/${run.id}/stop");
    final response = await http.post(url);
    return response.statusCode == 200;
  }
}
