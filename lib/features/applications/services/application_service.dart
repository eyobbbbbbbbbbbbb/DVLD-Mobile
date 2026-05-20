import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/models/license_class.dart';

class ApplicationService {
  static Future<List<LicenseClass>> getLicenseClasses() async {
    try {
      final response = await ApiClient.get('/applications/classes');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LicenseClass.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching license classes: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitLocalApplication({
    required int personId,
    required int licenseClassId,
    required int instituteId,
  }) async {
    try {
      final response = await ApiClient.post('/applications/new-local', {
        'applicantPersonID': personId,
        'licenseClassID': licenseClassId,
        'drivingInstituteID': instituteId,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      
      // Try to get specific error message from backend
      String message = 'Failed to create application.';
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error.containsKey('message')) {
          message = error['message'];
        } else {
          message = error.toString();
        }
      } catch (_) {}
      
      return {
        'success': false, 
        'message': message
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<Map<String, dynamic>>> getApplicationStatus(int personId) async {
    try {
      final response = await ApiClient.get('/applications/status/$personId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTestHistory(int ldlAppId) async {
    try {
      final response = await ApiClient.get('/applications/test-history/$ldlAppId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getNextTest(int ldlAppId) async {
    try {
      final response = await ApiClient.get('/applications/next-test/$ldlAppId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<double> getApplicationFee(int typeId) async {
    try {
      final response = await ApiClient.get('/applications/fees/$typeId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['fees'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
