import 'dart:convert';
import 'dart:io';
import '../../../core/api/api_client.dart';

class OcrService {
  /// Takes an image [File], sends it to the backend OCR endpoint,
  /// and returns a map of all extracted Ethiopian ID fields.
  /// Returns null if the scan fails entirely.
  static Future<Map<String, String?>?> scanIdCard(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final response = await ApiClient.post('/ocr/scan-id', {
        'imageBase64': base64Image,
        'mimeType': mimeType,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'fullName':    data['fullName'],
          'dateOfBirth': data['dateOfBirth'],
          'gender':      data['gender'],
          'nationalId':  data['nationalId'],  // FAN number
          'phone':       data['phone'],
          'nationality': data['nationality'],
          'address':     data['address'],
        };
      }
      return null;
    } catch (e) {
      print('OCR scan error: $e');
      return null;
    }
  }
}
