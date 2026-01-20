import 'dart:convert';
import 'package:http/http.dart' as http; // Assume http package

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({required this.baseUrl, required this.client});

  Future<dynamic> get(String endpoint) async {
    final response = await client.get(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}
