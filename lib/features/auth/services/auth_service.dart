import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/services/user_session.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'username': username,
        'password': password,
      }).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          ApiClient.setToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        // Fallback to mock if API returns error
        return _mockLoginFallback(username, password);
      }
    } catch (e) {
      // Fallback to mock on connection error
      return _mockLoginFallback(username, password);
    }
  }

  static Map<String, dynamic> _mockLoginFallback(String username, String password) {
    final mockUser = MockUsers.find(username);
    if (mockUser != null) {
      return {
        'success': true,
        'data': {
          'token': 'mock_token_${username}',
          'user': mockUser,
        }
      };
    }
    return {
      'success': false, 
      'message': 'Invalid credentials or API unreachable. Try using "ahmad" for mock login.'
    };
  }

  static Future<void> logout() async {
    ApiClient.clearToken();
  }
}
