import 'dart:convert';
import 'package:http/http.dart' as http;

class THttpHelper {
  static const String _baseUrl =
      'https://your-api-base-url.com'; // Replace with your API base URL

  // Generalized request method
  static Future<Map<String, dynamic>> _request(String method, String endpoint,
      {dynamic data}) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final headers = {'Content-Type': 'application/json'};
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri);
          break;
        case 'POST':
          response =
              await http.post(uri, headers: headers, body: json.encode(data));
          break;
        case 'PUT':
          response =
              await http.put(uri, headers: headers, body: json.encode(data));
          break;
        case 'DELETE':
          response = await http.delete(uri);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  // Public methods for API requests
  static Future<Map<String, dynamic>> get(String endpoint) =>
      _request('GET', endpoint);
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data) =>
      _request('POST', endpoint, data: data);
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) =>
      _request('PUT', endpoint, data: data);
  static Future<Map<String, dynamic>> delete(String endpoint) =>
      _request('DELETE', endpoint);

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode}, ${response.body}');
    }
  }
}
