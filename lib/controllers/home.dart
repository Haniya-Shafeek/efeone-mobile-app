import 'dart:ffi';

import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/view/login_view.dart';
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
  //Tasks
  List<String> _taskname = [];
  List<String> _tasksub = [];
  List<String> _taskdes = [];
  List<String> _taskstatus = [];
  List<String> _startdate = [];
  List<String> _taskowner = [];
  List<String> _openTaskNames = [];
  List<String> _openTaskSub = [];
  List<String> _openTaskSts = [];
  List<String> _openTaskdes = [];
  List<String> _openTaskOwner = [];
  List<String> _workingTaskNames = [];
  List<String> _workingTaskSub = [];
  List<String> _workingTaskSts = [];
  List<String> _workingTaskdes = [];
  List<String> _workingTaskOwner = [];
  List<String> _pendingReviewTaskNames = [];
  List<String> _pendingReviewTaskSub = [];
  List<String> _pendingReviewTaskSts = [];
  List<String> _pendingReviewgTaskdes = [];
  List<String> _pendingReviewTaskOwner = [];
  List<String> _overdueTaskNames = [];
  List<String> _overdueTaskSub = [];
  List<String> _overdueTaskSts = [];
  List<String> _overdueTaskdes = [];
  List<String> _overdueTaskOwner = [];
  List<String> _templateTaskNames = [];
  List<String> _templateTaskSub = [];
  List<String> _templateTaskSts = [];
  List<String> _templateTaskdes = [];
  List<String> _templateTaskOwner = [];

  //Todo
  List<String> _todoname = [];
  List<String> _todotype = [];
  List<String> _tododes = [];
  List<String> _todosts = [];
  List<String> _todoassgn = [];
  List<String> _todomodify = [];
  List<String> _tododate = [];
  final List<String> _todosub = [];

  String get username => _username;
  String get logtime => _logtime;
  String get logtype => _logtype;
  String get imgurl => _imgurl;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  //Getters Tasks
  List<String> get taskname => _taskname;
  List<String> get tasksub => _tasksub;
  List<String> get taskdes => _taskdes;
  List<String> get tasksts => _taskstatus;
  List<String> get startdate => _startdate;
  List<String> get taskowner => _taskowner;
  List<String> get openTaskNames => _openTaskNames;
  List<String> get openTaskSub => _openTaskSub;
  List<String> get openTaskSts => _openTaskSts;
  List<String> get openTaskdes => _openTaskdes;
  List<String> get openTaskowner => _openTaskOwner;
  List<String> get workingTaskNames => _workingTaskNames;
  List<String> get workingTaskSub => _workingTaskSub;
  List<String> get workingTaskSts => _workingTaskSts;
  List<String> get workingTaskdes => _workingTaskdes;
  List<String> get workingTaskowner => _workingTaskOwner;
  List<String> get pendingReviewTaskNames => _pendingReviewTaskNames;
  List<String> get pendingReviewTaskSub => _pendingReviewTaskSub;
  List<String> get pendingReviewTaskSts => _pendingReviewTaskSts;
  List<String> get pendingReviewTaskdes => _pendingReviewgTaskdes;
  List<String> get pendingReviewTaskowner => _pendingReviewTaskOwner;
  List<String> get overdueTaskNames => _overdueTaskNames;
  List<String> get overdueTaskSub => _overdueTaskSub;
  List<String> get overdueTaskSts => _overdueTaskSts;
  List<String> get overdueTaskdes => _overdueTaskdes;
  List<String> get overdueTaskowner => _overdueTaskOwner;
  List<String> get templateTaskNames => _templateTaskNames;
  List<String> get templateTaskSub => _templateTaskSub;
  List<String> get templateTaskSts => _templateTaskSts;
  List<String> get templateTaskdes => _templateTaskdes;
  List<String> get templateTaskowner => _templateTaskOwner;

  //Getters Todo
  List<String> get todoname => _todoname;
  List<String> get todotype => _todotype;
  List<String> get tododes => _tododes;
  List<String> get todosts => _todosts;
  List<String> get todoassgn => _todoassgn;
  List<String> get todomodify => _todomodify;
  List<String> get tododate => _tododate;
  List<String> get todosub => _todosub;

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
  Future<void> toggleCheckInStatus( double latitude,double logiude) async {
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

      await postStatus(status, currentTime,logiude,logiude);
    } catch (e) {
      print('Error toggling check-in status: $e');
    }
  }

  // Post check-in status to server
  Future<void> postStatus(String status, String currentTime, double latitude, double longitude) async {
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
        '${Config.baseUrl}/api/resource/Employee%20Checkin?filters=[["employee", "=", "$employeeid"]]&fields=["name","log_type","employee","time"]&order_by=creation desc&limit=1';
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
          final String formattedDate =
              DateFormat('MMM dd HH:mm:ss').format(parsedDate);
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

  // Fetch user's tasks from server
  Future<void> fetchTask(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final user = prefs.getString('usr');
    final url =
        '${Config.baseUrl}/api/resource/Task?fields=["name","subject","description","status","exp_start_date","owner"]&filters=[["_assign", "like", "%$user%"]]';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> tasks = jsonDecode(response.body)['data'];
        DateFormat formatter = DateFormat('MMM dd, yyyy');

        _taskname = tasks.map((task) => task['name'].toString()).toList();
        _tasksub = tasks.map((task) => task["subject"].toString()).toList();
        _taskdes = tasks.map((task) => task["description"].toString()).toList();
        _taskstatus = tasks.map((task) => task["status"].toString()).toList();
        _startdate = tasks.map((task) {
          if (task["exp_start_date"] != null) {
            DateTime date = DateTime.parse(task["exp_start_date"]);
            return formatter.format(date);
          } else {
            return 'Date not available';
          }
        }).toList();

        _taskowner = tasks.map((task) => task["owner"].toString()).toList();

        // Open tasks
        _openTaskNames = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['name'].toString())
            .toList();
        _openTaskSub = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['subject'].toString())
            .toList();
        _openTaskdes = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['description'].toString())
            .toList();
        _openTaskOwner = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['owner'].toString())
            .toList();
        _openTaskSts = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['status'].toString())
            .toList();

        // Working tasks
        _workingTaskNames = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['name'].toString())
            .toList();
        _workingTaskSub = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['subject'].toString())
            .toList();
        _workingTaskdes = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['description'].toString())
            .toList();
        _workingTaskOwner = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['owner'].toString())
            .toList();
        _workingTaskSts = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['status'].toString())
            .toList();

        // Pending review tasks
        _pendingReviewTaskNames = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['name'].toString())
            .toList();
        _pendingReviewTaskSub = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['subject'].toString())
            .toList();
        _pendingReviewgTaskdes = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['description'].toString())
            .toList();
        _pendingReviewTaskOwner = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['owner'].toString())
            .toList();
        _pendingReviewTaskSts = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['status'].toString())
            .toList();

        // Overdue tasks
        _overdueTaskNames = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['name'].toString())
            .toList();
        _overdueTaskSub = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['subject'].toString())
            .toList();
        _overdueTaskdes = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['description'].toString())
            .toList();
        _overdueTaskOwner = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['owner'].toString())
            .toList();
        _overdueTaskSts = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['status'].toString())
            .toList();

        // Template tasks
        _templateTaskNames = tasks
            .where((task) => task['status'] == 'Template')
            .map((task) => task['name'].toString())
            .toList();
        _templateTaskSub = tasks
            .where((task) => task['status'] == 'Template')
            .map((task) => task['subject'].toString())
            .toList();
        _templateTaskdes = tasks
            .where((task) => task['status'] == 'Template')
            .map((task) => task['description'].toString())
            .toList();
        _templateTaskOwner = tasks
            .where((task) => task['status'] == 'Template')
            .map((task) => task['owner'].toString())
            .toList();
        _templateTaskSts = tasks
            .where((task) => task['status'] == 'Template')
            .map((task) => task['status'].toString())
            .toList();

        notifyListeners();
      } else if (response.statusCode == 401) {
        // Unauthorized: Token expired
        await _handleTokenExpiry(context);
      } else {
        throw Exception(
            'Failed to load task subjects. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching task subjects: $e');
    }
  }

  // Fetch user's todos from server
  Future<void> fetchTodo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final url =
        '${Config.baseUrl}/api/resource/ToDo?fields=["name","reference_type","description","status","assigned_by_full_name","modified_by","date"]';
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

        List<dynamic> todos = data['data'];
        DateFormat formatter = DateFormat('MMM dd, yyyy');

        _todoname = todos.map((todo) => todo['name'] as String).toList();
        _tododes = todos.map((todo) => todo["description"] as String).toList();
        _todosts = todos.map((todo) => todo["status"] as String).toList();
        _todomodify =
            todos.map((todo) => todo["modified_by"] as String).toList();
        _tododate = todos
            .map((todo) {
              if (todo["date"] != null) {
                DateTime date = DateTime.parse(todo["date"]);
                return formatter.format(date);
              } else {
                return null; // Handle the null case as you prefer
              }
            })
            .where((date) => date != null)
            .cast<String>()
            .toList();
        _todoassgn = todos
            .map((todo) => todo["assigned_by_full_name"] as String)
            .toList();

        _todotype =
            todos.map((todo) => todo["reference_type"] as String).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load ToDo names');
      }
    } catch (e) {
      print('Error fetching task subjects: $e');
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
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Loginscreen(),
        ),
        (route) => false);
  }
}
