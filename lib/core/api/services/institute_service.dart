import 'dart:convert';
import '../api_client.dart';
import '../models/driving_institute.dart';

class InstituteService {
  static Future<List<DrivingInstitute>> getAllInstitutes({String? city, String? region}) async {
    try {
      // If no filters, use the plain "all" endpoint
      // If filters provided, use the dedicated /filter endpoint
      bool hasFilter = (city != null && city.isNotEmpty) || (region != null && region.isNotEmpty);
      String endpoint;

      if (hasFilter) {
        Map<String, String> queryParams = {};
        if (city != null && city.isNotEmpty) queryParams['city'] = city;
        if (region != null && region.isNotEmpty) queryParams['region'] = region;
        endpoint = '/applications/institutes/filter?' + Uri(queryParameters: queryParams).query;
      } else {
        endpoint = '/applications/institutes';
      }

      final response = await ApiClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DrivingInstitute.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching institutes: $e');
      return [];
    }
  }

  static Future<Map<String, List<String>>> getFilters() async {
    try {
      final response = await ApiClient.get('/applications/institutes/filters');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'cities': List<String>.from(data['cities']),
          'regions': List<String>.from(data['regions']),
        };
      }
      return {'cities': [], 'regions': []};
    } catch (e) {
      print('Error fetching filters: $e');
      return {'cities': [], 'regions': []};
    }
  }
}
