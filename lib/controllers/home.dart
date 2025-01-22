import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/widgets/cust_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomepageController extends ChangeNotifier {
  String _username = '';
  String _imgurl = '';
  String _logtime = '';
  String _logtype = '';
  bool _isCheckedIn = true;
  DateTime? _checkInTime;

  String get username => _username;
  String get logtime => _logtime;
  String get logtype => _logtype;
  String get imgurl => _imgurl;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;

  HomepageController() {
    initialize();
  }
  // Initialize user data from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('fullName') ?? 'User';
    _imgurl = prefs.getString('img_url') ?? '';
    _logtime = prefs.getString('log_time') ?? '';
    _logtype = prefs.getString('log_type') ?? '';
    _isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
    String? checkInTimeStr = prefs.getString('checkInTime');
    if (checkInTimeStr != null) {
      _checkInTime = DateTime.parse(checkInTimeStr);
    }
    notifyListeners();
    // Fetch the last check-in details
    await fetchLastLoginType();
  }

  // Toggle check-in status
  Future<void> toggleCheckInStatus(double latitude, double logiude,BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCheckedIn = !_isCheckedIn;

      if (_isCheckedIn) {
        _checkInTime = DateTime.now();
        await prefs.setString('checkInTime', _checkInTime!.toIso8601String());
      } else {
        _checkInTime = null;
        await prefs.remove('checkInTime');
      }

      await prefs.setBool('isCheckedIn', _isCheckedIn);
      notifyListeners();

      String currentTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String status = _isCheckedIn ? 'IN' : 'OUT';

      await postStatus(status, currentTime, latitude, logiude,context);
    } catch (e) {
      print('Error toggling check-in status: $e');
    }
  }

  // Post check-in status to server
  Future<void> postStatus(String status, String currentTime, double latitude,
      double longitude, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final employeeId = prefs.getString('employeeid');

    if (token == null || employeeId == null) {
      print('Token or employee ID is missing');
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/api/resource/Employee Checkin');

    final Map<String, dynamic> requestData = {
      'employee': employeeId,
      'log_type': status,
      'time': currentTime,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'cookie': token,
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print('Status posted successfully: $status at $currentTime');
        print(response.body);

        // Update local state and SharedPreferences
        _logtime = currentTime;
        _logtype = status;
        await prefs.setString('log_time', _logtime);
        await prefs.setString('log_type', _logtype);

        notifyListeners();
      } else {
        print('Failed to post status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting status: $e');
      CustomSnackbar.showSnackbar(
          context: context,
          message: 'Error Posting status',
          bgColor: Colors.orange);
    }
  }

  // Fetch last login type from server
  Future<void> fetchLastLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeid = prefs.getString('employeeid');
    final token = prefs.getString('cookie');

    if (employeeid == null || token == null) {
      print('Employee ID or token is missing');
      return;
    }

    final url =
        '${Config.baseUrl}/api/resource/Employee%20Checkin?filters=[["employee", "=", "$employeeid"]]&fields=["*"]&order_by=creation desc&limit=1';
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final logtime = data['data'][0]['time'];
          final logtype = data['data'][0]['log_type'];

          final DateTime parsedDate = DateTime.parse(logtime);
          final String formattedDate = DateFormat('HH:mm a').format(parsedDate);
          // Update SharedPreferences and internal state
          await prefs.setString('log_time', formattedDate);
          _logtime = formattedDate;
          await prefs.setString('log_type', logtype);
          _logtype = logtype;

          _isCheckedIn = logtype != 'OUT';
          await prefs.setBool('isCheckedIn', _isCheckedIn);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load last login type');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //token expiry handle
  Future<void> _handleTokenExpiry(BuildContext context) async {
    // Clear current session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("cookie");
    await prefs.remove("employeeid");
    await prefs.remove("fullName");

    // Redirect to login page
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }
}
