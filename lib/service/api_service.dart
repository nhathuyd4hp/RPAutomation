import 'dart:convert';
import 'package:http/http.dart' as http;

class HTTPClient {
  final String backend;

  HTTPClient({required this.backend});

  Future<dynamic> getRobots() async {
    final url = Uri.parse("$backend/api/robots");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data;
  }
}
