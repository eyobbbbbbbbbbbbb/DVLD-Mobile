import 'dart:convert';
import '../../../core/api/api_client.dart';

class DetainService {
  static Future<Map<String, dynamic>?> checkDetainStatus(int licenseId) async {
    try {
      final response = await ApiClient.get('/detainedlicenses/is-detained/$licenseId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDetainInfo(int licenseId) async {
    try {
      final response = await ApiClient.get('/detainedlicenses/info/$licenseId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> releaseLicense(int licenseId, int userId) async {
    try {
      final response = await ApiClient.post('/detainedlicenses/release', {
        'licenseID': licenseId,
        'createdByUserID': userId,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
