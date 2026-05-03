import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/services/user_session.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'username': username,
        'password': password,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          ApiClient.setToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String secondName,
    required String thirdName,
    required String lastName,
    required String nationalNo,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String address,
    required DateTime dateOfBirth,
    required int gender,
    required int nationalityCountryId,
  }) async {
    try {
      final response = await ApiClient.post('/auth/register', {
        'firstName': firstName,
        'secondName': secondName,
        'thirdName': thirdName,
        'lastName': lastName,
        'nationalNo': nationalNo,
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'nationalityCountryID': nationalityCountryId,
        'imagePath': "", // Placeholder for now
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<void> logout() async {
    ApiClient.clearToken();
  }
}
