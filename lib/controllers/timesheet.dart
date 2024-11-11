import 'dart:convert';
import 'dart:ffi';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetRowAdd_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:http/http.dart' as http;
import 'package:efeone_mobile/utilities/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimesheetController extends ChangeNotifier {
  String? _empid;
  String? _empname;
  List<Map<String, dynamic>> _timesheet = [];
  List<dynamic> _activityType = [];
  List<dynamic> _projects = [];
  Map<String, dynamic>? _timesheetData;
  final List<Map<String, dynamic>> _timeLogs = [];
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? selectedCategory;
  String? selectedProject;
  bool isCompleted = false;
  bool isDataFetched = false;

  String? get empid => _empid;
  String? get empname => _empname;
  String? get postingDate => _postingDate();
  List<Map<String, dynamic>> get timesheet => _timesheet;
  List<dynamic> get projects => _projects;
  List<dynamic> get activitytype => _activityType;
  Map<String, dynamic>? get timesheetData => _timesheetData;
  List<Map<String, dynamic>>? get timeLogs => _timeLogs;
  Map<String, dynamic>? _timesheetDetails;
  Map<String, dynamic>? get timesheetDetail => _timesheetDetails;

  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController endOfDayReviewController =
      TextEditingController();
  final TextEditingController tomorrowPlanController = TextEditingController();

  //Method to fetch shared preference value
  Future<void> loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    employeeIdController.text = prefs.getString('employeeid') ?? '';
    _empid = prefs.getString('employeeid') ?? '';
    employeeNameController.text = prefs.getString('fullName') ?? '';
    _empname = prefs.getString('fullName') ?? '';
    notifyListeners();
  }

  //Method to fetch timesheet id
  Future<void> fetchTimesheetDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      // final String employeeId = prefs.getString('employeeid') ?? '';
      final url = Uri.parse(
          '${Config.baseUrl}/api/resource/Timesheet?fields=["*"]&order_by=creation%20desc');
      print(url);
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/api/resource/Timesheet?fields=["*"]&order_by=creation%20desc'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          _timesheet = List<Map<String, dynamic>>.from(jsonData['data']);
          isDataFetched = true;
          notifyListeners();
        } else {
          print('Invalid response format');
        }
      } else {
        print('Failed to fetch timesheet details: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

//Method to fetch singletimesheet
  Future<void> fetchSingleTimesheetDetails(String timesheetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          Uri.parse('${Config.baseUrl}/api/resource/Timesheet/$timesheetId');
      print(url);
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/resource/Timesheet/$timesheetId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data')) {
          // Assuming _timesheetDetails holds the fetched details for the timesheet
          _timesheetDetails = jsonData['data'];
          notifyListeners(); // Update state for UI to reflect the new data
        } else {
          print('Invalid response format');
        }
      } else {
        print('Failed to fetch timesheet details:');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  // Method to set timesheet data
  void setTimesheetData(Map<String, dynamic> data) {
    _timesheetData = data;
    notifyListeners();
  }

  // Method to fetch timesheet data
  Future<Map<String, dynamic>> fetchTimesheetData(String timesheetId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("cookie");

    final url = '${Config.baseUrl}/api/resource/Timesheet/$timesheetId';
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming you want to return the 'data' field from the response
        return data['data']; // Return the 'data' object directly
      } else {
        throw Exception('Failed to load timesheet data: ${response.body}');
      }
    } catch (error) {
      print('Error fetching timesheet data: $error');
      rethrow; // Rethrow the error to handle it in FutureBuilder
    }
  }

  //Method to post timesheet as draft
  Future<void> postTimesheet(
      {required String postingDate,
      required List<Map<String, dynamic>> timeLogs,
      required String note,
      String? eodReview,
      String? tmrwplan,
      required BuildContext context}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final empid = prefs.getString('employeeid');

      final timesheetData = {
        "posting_date": postingDate,
        "employee": empid,
        "note": note,
        "end_of_the_day_review": eodReview,
        "tomorrows_plan": tmrwplan,
        "time_logs": timeLogs
      };
      final url = Uri.parse('${Config.baseUrl}/api/resource/Timesheet');
      print(url);
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/resource/Timesheet'),
        headers: {
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
        body: jsonEncode(timesheetData),
      );

      if (response.statusCode == 200) {
        // Success handling
        final responseData = jsonDecode(response.body);
        final timesheetName = responseData['data']['name'];
        Provider.of<TimesheetController>(context, listen: false)
            .setTimesheetName(timesheetName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: custom_text(
                text: 'Successly Posted',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));

        print('Timesheet created successfully: ${response.body}');
      } else {
        // Error handling
        print('Failed to create timesheet: ${response.body}');
      }
    } catch (error) {
      print('An error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  //Mathod to submit timesheet by changing docstatus
  Future<void> submitTimesheet(
      String timesheetName, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");

      final updateData = {
        "docstatus": 1 // Setting as Submitted
      };
      final url =
          Uri.parse('${Config.baseUrl}/api/resource/Timesheet/$timesheetName');
      print(url);
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/resource/Timesheet/$timesheetName'),
        headers: {
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        // Success handling
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: custom_text(
                text: 'Timesheet submitted successfully',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TimesheetListviewScreen(),
          ),
        );
      } else {
        // Error handling
        print('Failed to submit timesheet: ${response.body}');
      }
    } catch (error) {
      print('An error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

//Method To update the timesheet
  Future<bool> updateTimesheet(String timesheetId, Map<String, dynamic> data,
      BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          "${Config.baseUrl}/api/resource/Timesheet/$timesheetId"; // Replace with actual endpoint
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Optionally, parse the response data if needed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: custom_text(
                text: 'Timesheet updated successfully',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));

        Navigator.pop(context, true);
        notifyListeners();
        return true;
      } else {
        // Log or handle errors
        print("Failed to update timesheet: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Error updating timesheet: $error");
      return false;
    }
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Error',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //Method to delete timesheet
  Future<void> deleteTimesheet(String timesheetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url = '${Config.baseUrl}/api/resource/Timesheet/$timesheetId';
      print(url);
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        print("Successfully deleted");
      } else {
        throw Exception('Failed to load timesheet data ${response.body}');
      }
    } catch (error) {
      print('Error fetching timesheet data: $error');
      // Handle the error accordingly
    }
  }

  //Method to fetch project Name
  Future fetchprojectType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          '${Config.baseUrl}/api/resource/Project?limit_page_length=1000';
      print(url);
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List<dynamic>;
        _projects = data.map((item) => item as Map<String, dynamic>).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load projectname data ${response.body}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

//Method to fetch Activity Type
  Future fetchActivitytype() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          '${Config.baseUrl}/api/resource/Activity%20Type?limit_page_length=1000';
      print(url);
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List<dynamic>;
        _activityType = (data
            .map((item) => item as Map<String, dynamic>)
            .toList()
          ..sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String)));
        notifyListeners();
      } else {
        throw Exception('Failed to load projectname data ${response.body}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

// Date pickers
  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      selectedDate = pickedDate;
      notifyListeners();
    }
  }

  //Time picker
  Future<void> pickStartTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedStartTime = pickedTime;
      notifyListeners();
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedEndTime = pickedTime;
      notifyListeners();
    }
  }

  // Validation and adding time logs
  void addTimeLog(BuildContext context) {
    if (selectedDate != null &&
        selectedStartTime != null &&
        selectedEndTime != null &&
        selectedCategory != null &&
        selectedProject != null &&
        descriptionController.text.isNotEmpty) {
      final fromTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedStartTime!.hour,
        selectedStartTime!.minute,
      );

      final toTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute,
      );

      if (fromTime.isAfter(toTime)) {
        _showErrorDialog(context, 'Start time must be before end time.');
        return;
      }

      final timeLogExists = _timeLogs.any((log) {
        final logStart = DateTime.parse(log['from_time']);
        final logEnd = DateTime.parse(log['to_time']);
        return (fromTime.isBefore(logEnd) && toTime.isAfter(logStart));
      });

      if (timeLogExists) {
        _showErrorDialog(context,
            'The selected time slot overlaps with an existing time slot.');
        return;
      }
      final duration = toTime.difference(fromTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final formattedDuration = '${hours}h ${minutes}m';

      _timeLogs.add({
        "activity_type": selectedCategory!,
        "from_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(fromTime),
        "to_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(toTime),
        "description": descriptionController.text,
        "completed": isCompleted ? 1 : 0,
        "project": selectedProject!,
        "hours": formattedDuration
      });

      descriptionController.clear();
      selectedDate = null;
      selectedStartTime = null;
      selectedEndTime = null;
      selectedCategory = null;
      selectedProject = null;
      isCompleted = false;

      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

//To show error dialogue
  // void _showErrorDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  //Method to format posting date
  String _postingDate() {
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(DateTime.now());
  }

//Method to add timelog row
  void addtimeLog(Map<String, dynamic> newLog) {
    // Assign an index to the new log entry
    final index = timeLogs!.isNotEmpty ? timeLogs!.last['index'] + 1 : 1;
    newLog['index'] = index;
    timeLogs!.add(newLog);
    notifyListeners();
  }

  // Method to delete a time log entry based on the index
  void deleteTimeLog(int index) {
    timeLogs?.removeWhere((log) => log['index'] == index);
    notifyListeners();
  }

  // Method to clear time logs
  void clearTimeLogs() {
    timeLogs?.clear();
    notifyListeners();
  }

  // Method To add empty row
  void addEmptyLog(BuildContext context) {
    print('row add called');
    timeLogs!.add({
      'index': timeLogs!.length + 1,
      'activity_type': '',
      'from_Time': '',
      'hours': 0,
      'project': '',
      "Edit": IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TimesheetRowaddview(
                      timeLog: {},
                    )),
          );
        },
        icon: const Icon(Icons.edit, color: Colors.grey),
      ),
    });
    notifyListeners(); // Notify the UI to rebuild with the new row
  }

  bool _isSaved = false;

  bool get isSaved => _isSaved;

  void toggleSaved() {
    _isSaved = true;
    notifyListeners();
  }

  void resetSavedStatus() {
    _isSaved = false;
    notifyListeners();
  }

  String? _timesheetName;

  String? get timesheetName => _timesheetName;

//Method to get timesheetname
  void setTimesheetName(String name) {
    _timesheetName = name;
    notifyListeners();
  }

  void updateTimeLog(int index, dynamic updatedLog) {
    timeLogs![index] = updatedLog;
    notifyListeners(); // Notify the UI to rebuild
  }
  void addEmptyLogtimelog(BuildContext context) {
    timeLogs!.add({
      'activity_type': '',
      'from_time': '',
      'to_time': '',
      'hours': 0,
      'project': '',
    });
    notifyListeners(); // This will notify the UI to rebuild
  }
}
