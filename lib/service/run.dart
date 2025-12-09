import 'dart:convert';
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
}
