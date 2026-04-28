import 'dart:convert';
import '../../../core/api/api_client.dart';

class InternationalLicenseService {
  static Future<List<Map<String, dynamic>>> getPersonLicenses(int personId) async {
    try {
      final response = await ApiClient.get('/internationallicenses/person/$personId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> issueLicense({
    required int localLicenseId,
    required int userId,
  }) async {
    try {
      final response = await ApiClient.post('/internationallicenses/issue', {
        'localLicenseId': localLicenseId,
        'createdByUserId': userId,
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
