import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/services/message_service.dart';
import '../services/user_session.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Timer? _pollingTimer;
  bool _isPolling = false;

  // Track the last seen count to prevent duplicate popups
  int _lastHandledCount = 0;

  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    
    // Initial fetch
    _fetchCount(isInitial: true);

    // Periodic fetch every 60 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _fetchCount();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _isPolling = false;
  }

  Future<void> _fetchCount({bool isInitial = false}) async {
    try {
      final personId = UserSession.instance.personId;
      if (personId <= 0) return;

      final count = await MessageService.getUnreadCount(personId);
      
      if (count != _unreadCount) {
        // If count increased, we notify the UI to show a popup
        if (!isInitial && count > _unreadCount) {
          _notifyNewMessage();
        }
        
        _unreadCount = count;
        if (isInitial) _lastHandledCount = count;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error in notification polling: $e');
    }
  }

  // This stream will be used by the UI to show the Snackbar
  final _notificationStreamController = StreamController<bool>.broadcast();
  Stream<bool> get onNewNotification => _notificationStreamController.stream;

  void _notifyNewMessage() {
    HapticFeedback.vibrate();
    _notificationStreamController.add(true);
  }

  void refreshManual() {
    _fetchCount();
  }

  @override
  void dispose() {
    stopPolling();
    _notificationStreamController.close();
    super.dispose();
  }
}
