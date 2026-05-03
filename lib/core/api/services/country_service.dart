import 'dart:convert';
import '../api_client.dart';
import '../models/country.dart';

class CountryService {
  static Future<List<Country>> getAllCountries() async {
    try {
      final response = await ApiClient.get('/countries');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
