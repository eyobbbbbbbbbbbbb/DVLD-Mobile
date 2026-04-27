import 'dart:convert';
import '../../../core/api/api_client.dart';

class DriverService {
  static Future<List<Map<String, dynamic>>> getDriverHistory(int personId) async {
    try {
      final response = await ApiClient.get('/drivers/history/$personId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
