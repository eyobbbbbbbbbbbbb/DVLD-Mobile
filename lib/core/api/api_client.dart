import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Use 10.0.2.2 for Android Emulator connecting to localhost.
  // Use your computer's IP address if testing on a physical device.
  static const String baseUrl = 'http://localhost:5000/api'; 
  
  static String? _authToken;

  static void setToken(String token) {
    _authToken = token;
  }

  static void clearToken() {
    _authToken = null;
  }

  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers());
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: _headers(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _headers());
  }
}
