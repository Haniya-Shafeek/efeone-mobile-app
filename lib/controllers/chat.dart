import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners(); // Notify widgets to rebuild
  }
}
