import 'dart:convert';
import '../api_client.dart';
import '../models/message.dart';

class MessageService {
  static Future<List<Message>> getMessages(int personId) async {
    try {
      final response = await ApiClient.get('/messages/$personId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  static Future<int> getUnreadCount(int personId) async {
    try {
      final response = await ApiClient.get('/messages/unread-count/$personId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> markAsRead(int messageId) async {
    try {
      final response = await ApiClient.patch('/messages/read/$messageId', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendMessage({
    required int personId,
    int? senderId,
    required String content,
    String title = 'Chat Message',
    String type = 'Chat',
  }) async {
    try {
      final response = await ApiClient.post('/messages/send', {
        'personID': personId,
        'senderID': senderId ?? personId,
        'title': title,
        'content': content,
        'messageType': type,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
