import 'dart:convert';
import '../../core/api/api_client.dart';

class PaymentService {
  /// Confirms a payment for a DVLD application and returns the receipt data.
  static Future<Map<String, dynamic>?> confirmPayment({
    required int applicationID,
    required String paymentMethod,
    String? chapaTransactionRef,
  }) async {
    try {
      final response = await ApiClient.post('/Payments/confirm', {
        'applicationID': applicationID,
        'paymentMethod': paymentMethod,
        if (chapaTransactionRef != null) 'chapaTransactionRef': chapaTransactionRef,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error confirming payment: $e');
    }
    return null;
  }

  /// Fetches the payment receipt for a DVLD application.
  static Future<Map<String, dynamic>?> getApplicationReceipt(int applicationID) async {
    try {
      final response = await ApiClient.get('/Payments/receipt/$applicationID');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching receipt: $e');
    }
    return null;
  }
}
