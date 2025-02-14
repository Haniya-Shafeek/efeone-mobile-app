import 'dart:convert';
import 'package:efeone_mobile/utilities/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Notificationcontroller extends ChangeNotifier {
  List<String> _taskname = [];
  List<String> _notassaign = [];
  List<String> _notdate = [];
  List<String> _notsub = [];
  List<String> _notread = [];
  List<String> _notname = [];
  int _unreadCount = 0;
  List<String> _nottype = [];

  //Getters notification
  List<String> get taskname => _taskname;
  List<String> get notassaign => _notassaign;
  List<String> get notdate => _notdate;
  List<String> get notsub => _notsub;
  List<String> get nottype => _nottype;
  List<String> get notread => _notread;
  List<String> get notname => _notname;
  int get unreadCount => _unreadCount;

  Notificationcontroller() {
    fetchNotifications();
  }

  // Fetch user's notifications from server
  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');

    final url =
        '${Config.baseUrl}/api/resource/Notification%20Log?fields=["*"]&order_by=creation desc';
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> notifications = data['data'];
        _taskname = notifications
            .map((task) => task['document_name'].toString())
            .toList();
        _notname =
            notifications.map((task) => task['name'].toString()).toList();
        _notassaign =
            notifications.map((task) => task['from_user'].toString()).toList();
        _notdate =
            notifications.map((task) => task['creation'].toString()).toList();
        _nottype = notifications
            .map((task) => task['document_type'].toString())
            .toList();
        _notsub =
            notifications.map((task) => task['subject'].toString()).toList();
        _notread =
            notifications.map((task) => task['read'].toString()).toList();

        _unreadCount = notifications
            .where((task) => task['read'].toString() == '0')
            .length;

        notifyListeners();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // Get the count of notifications
  int get notificationCount => _notread.length;

  //to mark notification as read
  Future<void> notificationRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final url =
        '${Config.baseUrl}/api/resource/Notification%20Log/$notificationId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token.toString()
        },
        body: json.encode({'read': "1"}),
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }
}
