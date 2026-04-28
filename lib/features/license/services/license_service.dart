import 'dart:convert';
import '../../../core/api/api_client.dart';

class LicenseService {
  static Future<List<Map<String, dynamic>>> getPersonLicenses(int personId) async {
    try {
      final response = await ApiClient.get('/licenses/person/$personId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getLicenseDetails(int licenseId) async {
    try {
      final response = await ApiClient.get('/licenses/$licenseId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> issueLicense({
    required int ldlApplicationId,
    required String notes,
    required int userId,
  }) async {
    try {
      final response = await ApiClient.post('/licenses/issue', {
        'localDrivingLicenseApplicationID': ldlApplicationId,
        'notes': notes,
        'createdByUserID': userId,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      
      String message = 'Failed to issue license.';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {}

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> renewLicense({
    required int licenseId,
    required String notes,
    required int userId,
  }) async {
    try {
      final response = await ApiClient.post('/licenses/renew', {
        'licenseID': licenseId,
        'notes': notes,
        'createdByUserID': userId,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      
      String message = 'Failed to renew license.';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {}

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> replaceLicense({
    required int licenseId,
    required int reason,
    required String notes,
    required int userId,
  }) async {
    try {
      final response = await ApiClient.post('/licenses/replace', {
        'licenseID': licenseId,
        'replacementReason': reason,
        'notes': notes,
        'createdByUserID': userId,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      
      String message = 'Failed to replace license.';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {}

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
