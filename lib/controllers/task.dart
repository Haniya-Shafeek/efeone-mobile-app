import 'dart:convert';

import 'package:efeone_mobile/utilities/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TaskController extends ChangeNotifier {
  List<String> _taskname = [];
  List<String> _tasksub = [];
  List<String> _taskdes = [];
  List<String> _taskproject = [];
  List<String> _taskstatus = [];
  List<String> _startdate = [];
  List<String> _taskowner = [];

  List<String> _openTaskNames = [];
  List<String> _openTaskendDate = [];
  List<String> _openTaskSub = [];
  List<String> _openTaskSts = [];
  List<String> _openTaskdes = [];
  List<String> _openTaskOwner = [];
  List<String> _openproject = [];
  List<String> _openTaskpriority = [];
  List<String> _openTasktype = [];
  List<String> _openTaskpartask = [];
 List<String> _openTaskcreation = [];

  List<String> _completeTaskNames = [];
  List<String> _completeTaskendDate = [];
  List<String> _completeTaskOwner = [];
  List<String> _completeTaskdes = [];
  List<String> _completeTaskSub = [];
  List<String> _completeTaskSts = [];
  List<String> _completeproject = [];
  List<String> _completeTasktype = [];
  List<String> _completeTaskpriority = [];
  List<String> _completeTaskpartask = [];
  List<String> _completeTaskcreation = [];

  List<String> _workingTaskNames = [];
  List<String> _workingTaskendDate = [];
  List<String> _workingTaskSub = [];
  List<String> _workingTaskSts = [];
  List<String> _workingTaskdes = [];
  List<String> _workingTaskOwner = [];
  List<String> _workingproject = [];
  List<String> _workingpriority = [];
  List<String> _workingtype = [];
  List<String> _workingpartask = [];
  List<String> _workingTaskcreation = [];

  List<String> _pendingReviewTaskNames = [];
  List<String> _pendingReviewTaskSub = [];
  List<String> _pendingReviewenddate = [];
  List<String> _pendingReviewTaskSts = [];
  List<String> _pendingReviewgTaskdes = [];
  List<String> _pendingReviewTaskOwner = [];
  List<String> _pendingproject = [];
  final List<String> _pendingpriority = [];
  List<String> _pendingtype = [];
  List<String> _pendingpartask = [];
  List<String> _pendingTaskcreation = [];

  List<String> _overdueTaskNames = [];
  List<String> _overdueTaskSub = [];
  List<String> _overdueTaskendDate = [];
  List<String> _overdueTaskSts = [];
  List<String> _overdueTaskdes = [];
  List<String> _overdueTaskOwner = [];
  List<String> _overdueproject = [];
  List<String> _overduekpriority = [];
  List<String> _overduetype = [];
  List<String> _overduepartask = [];
  List<String> _overdueTaskcreation = [];

  //Todo
  List<String> _todoname = [];
  List<String> _todotype = [];
  List<String> _tododes = [];
  List<String> _todosts = [];
  List<String> _todoassgn = [];
  List<String> _todomodify = [];
  List<String> _tododate = [];
  final List<String> _todosub = [];

  List<String> get taskname => _taskname;
  List<String> get tasksub => _tasksub;
  List<String> get taskdes => _taskdes;
  List<String> get tasksts => _taskstatus;
  List<String> get startdate => _startdate;
  List<String> get taskowner => _taskowner;
  List<String> get taskproject => _taskproject;

  List<String> get openTaskNames => _openTaskNames;
  List<String> get openTaskendDate => _openTaskendDate;
  List<String> get openTaskSub => _openTaskSub;
  List<String> get openTaskSts => _openTaskSts;
  List<String> get openTaskdes => _openTaskdes;
  List<String> get openTaskowner => _openTaskOwner;
  List<String> get openTaskproject => _openproject;
  List<String> get openTasktype => _openTasktype;
  List<String> get openTaskpriority => _openTaskpriority;
  List<String> get openTaskpartask => _openTaskpartask;
  List<String> get openTaskcreation => _openTaskcreation;

  List<String> get completeTaskNames => _completeTaskNames;
  List<String> get completeTaskendDate => _completeTaskendDate;
  List<String> get completeTaskSub => _completeTaskSub;
  List<String> get completeTaskSts => _completeTaskSts;
  List<String> get completeTaskdes => _completeTaskdes;
  List<String> get completeTaskowner => _completeTaskOwner;
  List<String> get completeTaskproject => _completeproject;
  List<String> get completeTasktype => _completeTasktype;
  List<String> get completeTaskpriority => _completeTaskpriority;
  List<String> get completeTaskpartask => _completeTaskpartask;
  List<String> get completeTaskcreation => _completeTaskcreation;

  List<String> get workingTaskNames => _workingTaskNames;
  List<String> get workingTaskSub => _workingTaskSub;
  List<String> get workingTaskebndDate => _workingTaskendDate;
  List<String> get workingTaskSts => _workingTaskSts;
  List<String> get workingTaskdes => _workingTaskdes;
  List<String> get workingTaskowner => _workingTaskOwner;
  List<String> get workingtaskproject => _workingproject;
  List<String> get workingtasktype => _workingtype;
  List<String> get workingtaskpriority => _workingpriority;
  List<String> get workingtaskpartask => _workingpartask;
  List<String> get workingTaskcreation => _workingTaskcreation;

  List<String> get pendingReviewTaskNames => _pendingReviewTaskNames;
  List<String> get pendindTaskendDate => _pendingReviewenddate;
  List<String> get pendingReviewTaskSub => _pendingReviewTaskSub;
  List<String> get pendingReviewTaskSts => _pendingReviewTaskSts;
  List<String> get pendingReviewTaskdes => _pendingReviewgTaskdes;
  List<String> get pendingReviewTaskowner => _pendingReviewTaskOwner;
  List<String> get pendingproject => _pendingproject;
  List<String> get pendingtype => _pendingtype;
  List<String> get pendingpriority => _pendingpriority;
  List<String> get pendingpartask => _pendingpartask;
  List<String> get pendingTaskcreation => _pendingTaskcreation;

  List<String> get overdueTaskNames => _overdueTaskNames;
  List<String> get overdueTaskSub => _overdueTaskSub;
  List<String> get overdueTaskSts => _overdueTaskSts;
  List<String> get overdueEndDate => _overdueTaskendDate;
  List<String> get overdueTaskdes => _overdueTaskdes;
  List<String> get overdueTaskowner => _overdueTaskOwner;
  List<String> get overdueproject => _overdueproject;
  List<String> get overduetype => _overduetype;
  List<String> get overduepriority => _overduekpriority;
  List<String> get overduepartask => _overduepartask;
  List<String> get overdueTaskcreation => _overdueTaskcreation;

  //Getters Todo
  List<String> get todoname => _todoname;
  List<String> get todotype => _todotype;
  List<String> get tododes => _tododes;
  List<String> get todosts => _todosts;
  List<String> get todoassgn => _todoassgn;
  List<String> get todomodify => _todomodify;
  List<String> get tododate => _tododate;
  List<String> get todosub => _todosub;

  int _totalTasksCount = 0;
  int _openTasksCount = 0;
  int _workingTasksCount = 0;
  int _pendingReviewTasksCount = 0;
  int _overdueTasksCount = 0;
  int _templateTasksCount = 0;

  int get totalTasksCount => _totalTasksCount;
  int get openTasksCount => _openTasksCount;
  int get workingTasksCount => _workingTasksCount;
  int get pendingReviewTasksCount => _pendingReviewTasksCount;
  int get overdueTasksCount => _overdueTasksCount;
  int get templateTasksCount => _templateTasksCount;

  // Fetch user's tasks from server
  Future<void> fetchTask(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final user = prefs.getString('usr')??"".toLowerCase();
    final url =
        '${Config.baseUrl}/api/resource/Task?fields=["name","creation","subject","description","status","exp_start_date","owner","act_end_date","project","parent_task","type","priority"]&filters=[["_assign", "like", "%$user%"]]&order_by=creation%20desc';
    print(' url : $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token.toString(),
        },
      );
      print('response  $response');

      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> tasks = jsonDecode(response.body)['data'];
        print(tasks);
        DateFormat formatter = DateFormat('MMM dd, yyyy');

        _taskname = tasks.map((task) => task['name'].toString()).toList();
        _tasksub = tasks.map((task) => task["subject"].toString()).toList();
        _taskdes = tasks.map((task) => task["description"].toString()).toList();
        _taskstatus = tasks.map((task) => task["status"].toString()).toList();
        _taskproject = tasks.map((task) => task["project"].toString()).toList();

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
        _openTaskendDate = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['act_end_date'].toString())
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
        _openproject = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['project'].toString())
            .toList();
        _openTasktype = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) => task['type'].toString())
            .toList();
        _openTaskpriority = tasks
            .where((task) => task['status'] == 'Open')
            .map(
                (task) => task['priority']?.toString() ?? "No priorityassigned")
            .toList();
        _openTaskpartask = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) =>
                task['parent_task']?.toString() ?? "No parent task assigned")
            .toList();
            _openTaskcreation = tasks
            .where((task) => task['status'] == 'Open')
            .map((task) =>
                task['creation']?.toString() ?? "")
            .toList();

        //Completed task
        _completeTaskNames = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['name'].toString())
            .toList();
        _completeTaskendDate = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['act_end_date'].toString())
            .toList();
        _completeTaskSub = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['subject'].toString())
            .toList();
        _completeTaskdes = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['description'].toString())
            .toList();

        _completeTaskOwner = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['owner'].toString())
            .toList();
        _completeTaskSts = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['status'].toString())
            .toList();
        _completeproject = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['project'].toString())
            .toList();
        _completeTasktype = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) => task['type'].toString())
            .toList();
        _completeTaskpriority = tasks
            .where((task) => task['status'] == 'Completed')
            .map(
                (task) => task['priority']?.toString() ?? "No priorityassigned")
            .toList();
        _completeTaskpartask = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) =>
                task['parent_task']?.toString() ?? "No parent task assigned")
            .toList();
            _completeTaskcreation = tasks
            .where((task) => task['status'] == 'Completed')
            .map((task) =>
                task['craetion']?.toString() ?? "")
            .toList();

        // Working tasks
        _workingTaskNames = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['name'].toString())
            .toList();
        _workingTaskendDate = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task["act_end_date"].toString())
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
        _workingproject = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['project'].toString())
            .toList();
        _workingtype = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['type'].toString())
            .toList();
        _workingpriority = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['priority'].toString())
            .toList();
        _workingpartask = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['parent_task'].toString())
            .toList();
            _workingTaskcreation = tasks
            .where((task) => task['status'] == 'Working')
            .map((task) => task['creation'].toString())
            .toList();

        // Pending review tasks
        _pendingReviewTaskNames = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['name'].toString())
            .toList();

        _pendingReviewenddate = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task["act_end_date"].toString())
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
        _pendingproject = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['project'].toString())
            .toList();
        _pendingtype = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['type'].toString())
            .toList();
        _pendingpartask = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['priority'].toString())
            .toList();
          _pendingTaskcreation = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['creation'].toString())
            .toList();

        _openTaskpartask = tasks
            .where((task) => task['status'] == 'Pending Review')
            .map((task) => task['parent_task'].toString())
            .toList();

        // Overdue tasks
        _overdueTaskNames = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['name'].toString())
            .toList();
        _overdueTaskendDate = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task["act_end_date"].toString())
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
        _overdueproject = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['project'].toString())
            .toList();
        _overduetype = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['type'].toString())
            .toList();
        _overduekpriority = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['priority'].toString())
            .toList();
        _overduepartask = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['parent_task'].toString())
            .toList();
            _overdueTaskcreation = tasks
            .where((task) => task['status'] == 'Overdue')
            .map((task) => task['creation'].toString())
            .toList();

        // Calculate the task counts
        _totalTasksCount = tasks.length;
        _openTasksCount =
            tasks.where((task) => task['status'] == 'Open').length;
        _workingTasksCount =
            tasks.where((task) => task['status'] == 'Working').length;
        _pendingReviewTasksCount =
            tasks.where((task) => task['status'] == 'Pending Review').length;
        _overdueTasksCount =
            tasks.where((task) => task['status'] == 'Overdue').length;
        _templateTasksCount =
            tasks.where((task) => task['status'] == 'Template').length;

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

  Future<void> _handleTokenExpiry(BuildContext context) async {
    // Clear current session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("cookie");
    await prefs.remove("employeeid");
    await prefs.remove("fullName");

    // Redirect to login page
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  // Fetch user's todos from server
  Future<void> fetchTodo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');
    final url =
        '${Config.baseUrl}/api/resource/ToDo?fields=["*"]&order_by=date%20desc';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'cookie': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");
        final data = jsonDecode(response.body);

        List<dynamic> todos = data['data'];
        DateFormat formatter = DateFormat('MMM dd, yyyy');

        // Clear previous data
        _todoname = [];
        _tododes = [];
        _todosts = [];
        _todomodify = [];
        _tododate = [];
        _todoassgn = [];
        _todotype = [];

        for (var todo in todos) {
          _todoname.add(todo['name'] ?? "No Name");
          _tododes.add(todo["description"] ?? "No Description");
          _todosts.add(todo["status"] ?? "Unknown");
          _todomodify.add(todo["modified_by"] ?? "Unknown");
          _todoassgn.add(todo["assigned_by_full_name"] ?? "Unknown");
          _todotype.add(todo["reference_type"] ?? "Unknown");

          // Handle null date safely
          if (todo["date"] != null) {
            DateTime date = DateTime.parse(todo["date"]);
            _tododate.add(formatter.format(date));
          } else {
            _tododate.add("No Date");
          }
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load ToDo names');
      }
    } catch (e) {
      print('Error fetching task subjects: $e');
    }
  }
}
