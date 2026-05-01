import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/api/models/driving_institute.dart';

class TrainingService {
  // Get all driving institutes
  Future<List<DrivingInstitute>> getAllInstitutes() async {
    try {
      final response = await ApiClient.get('/DrivingInstitutes');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DrivingInstitute.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching institutes: $e');
      return [];
    }
  }

  // Get student status (Enrollment + Batch)
  Future<Map<String, dynamic>?> getStudentStatus(int personId) async {
    try {
      final response = await ApiClient.get('/DrivingInstitutes/student/$personId/status');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching student status: $e');
      return null;
    }
  }

  // Get announcements for institute or batch
  Future<List<Map<String, dynamic>>> getAnnouncements(int instituteId, {int? batchId}) async {
    try {
      String url = '/DrivingInstitutes/$instituteId/announcements';
      if (batchId != null) {
        url += '?batchId=$batchId';
      }
      
      final response = await ApiClient.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Get attendance history for a batch
  Future<List<Map<String, dynamic>>> getAttendanceHistory(int batchId) async {
    try {
      final response = await ApiClient.get('/DrivingInstitutes/batches/$batchId/attendance');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  // Enroll student in an institute
  Future<bool> enroll(int personId, int instituteId, int userId) async {
    try {
      final response = await ApiClient.post('/DrivingInstitutes/enroll', {
        'personId': personId,
        'instituteId': instituteId,
        'createdByUserId': userId,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error enrolling student: $e');
      return false;
    }
  }
}
