import 'dart:convert';
import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeaveRequestProvider extends ChangeNotifier {
  String? _leaveType;
  String? _approver;
  String? _empid;
  String? _empname;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _reason;
  String? dateValidationError;
  bool _isHalfDay = false;
  DateTime? _halfDayDate;
  List<String>? _lwps;
  bool isLoading = false;
  double _totalLeaves = 0.0;
  double _expiredLeaves = 0.0;
  double _leavesTaken = 0.0;
  double _leavesPendingApproval = 0.0;
  double _remainingLeaves = 0.0;

  String? get leaveType => _leaveType;
  String? get approver => _approver;
  String? get empid => _empid;
  String? get empname => _empname;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get reason => _reason;
  bool get isHalfDay => _isHalfDay;
  DateTime? get halfDayDate => _halfDayDate;
  List<String>? get lwps => _lwps;

  Map<String, dynamic>? _leaveAllocation;
  Map<String, dynamic>? get leaveAllocation => _leaveAllocation;
  double get totalLeaves => _totalLeaves;
  double get expiredLeaves => _expiredLeaves;
  double get leavesTaken => _leavesTaken;
  double get leavesPendingApproval => _leavesPendingApproval;
  double get remainingLeaves => _remainingLeaves;

  final formKey = GlobalKey<FormState>();
  TextEditingController employeeIdController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  Future<void> loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    employeeIdController.text = prefs.getString('employeeid') ?? '';
    _empid = prefs.getString('employeeid') ?? '';
    employeeNameController.text = prefs.getString('fullName') ?? '';
    _empname = prefs.getString('fullName') ?? '';
    notifyListeners();
  }

  void setLeaveType(String? value) {
    _leaveType = value;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void setHalfDayDate(DateTime? date) {
    _halfDayDate = date;
    notifyListeners();
  }

  void setReason(String? value) {
    _reason = value;
    notifyListeners();
  }

  void setHalfDay(bool value) {
    _isHalfDay = value;
    notifyListeners();
  }

  Future<void> pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!,
              onPrimary: Colors.white,
              surface: Colors.blueGrey[900]!,
              onSurface: Colors.blueGrey[900]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startDate) {
      setStartDate(picked);
      validateDates(); // Validate dates after picking start date
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!,
              onPrimary: Colors.white,
              surface: Colors.blueGrey[900]!,
              onSurface: Colors.blueGrey[900]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != endDate) {
      setEndDate(picked);
      validateDates(); // Validate dates after picking end date
    }
  }

  Future<void> pickHalfDayDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: halfDayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!,
              onPrimary: Colors.white,
              surface: Colors.blueGrey[900]!,
              onSurface: Colors.blueGrey[900]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != halfDayDate) {
      setHalfDayDate(picked);
      validateDates(); // Validate dates after picking half-day date
    }
  }

  bool validateDates() {
    if (_startDate == null || _endDate == null) {
      dateValidationError = 'Please select both start and end dates';
      notifyListeners();
      return false;
    }
    if (_startDate!.isAfter(_endDate!)) {
      dateValidationError = 'Start date cannot be after end date';
      notifyListeners();
      return false;
    }
    if (_isHalfDay) {
      if (_halfDayDate == null) {
        dateValidationError = 'Please select a half-day date';
        notifyListeners();
        return false;
      }
      if (_halfDayDate!.isBefore(_startDate!) ||
          _halfDayDate!.isAfter(_endDate!)) {
        dateValidationError =
            'Half-day date must be within the start and end dates';
        notifyListeners();
        return false;
      }
    }
    dateValidationError = null; // Clear the error if validation passes
    notifyListeners();
    return true;
  }

  //fetch leave application type
  Future<List<String>> fetchLeaveDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final String employeeId = prefs.getString('employeeid') ?? '';

      // Format date as 'yyyy-MM-dd' without time
      final String date =
          DateFormat('yyyy-MM-dd').format(_startDate ?? DateTime.now());

      final url = Uri.parse(
          '${Config.baseUrl}/api/method/hrms.hr.doctype.leave_application.leave_application.get_leave_details?employee=$employeeId&date=$date');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Null check for leave allocation
        final leaveAllocation =
            jsonResponse['message']['leave_allocation']?['Casual Leave'];
        _approver = jsonResponse['message']['leave_approver'];
        _lwps = List<String>.from(jsonResponse['message']['lwps'] ?? []);

        if (leaveAllocation != null) {
          // Ensure that all fields are treated as doubles, only if leaveAllocation is not null
          _totalLeaves =
              (leaveAllocation['total_leaves'] as num?)?.toDouble() ?? 0.0;
          _expiredLeaves =
              (leaveAllocation['expired_leaves'] as num?)?.toDouble() ?? 0.0;
          _leavesTaken =
              (leaveAllocation['leaves_taken'] as num?)?.toDouble() ?? 0.0;
          _leavesPendingApproval =
              (leaveAllocation['leaves_pending_approval'] as num?)
                      ?.toDouble() ??
                  0.0;
          _remainingLeaves =
              (leaveAllocation['remaining_leaves'] as num?)?.toDouble() ?? 0.0;
        } else {
          // Handle the case when leaveAllocation is null
          _totalLeaves = 0.0;
          _expiredLeaves = 0.0;
          _leavesTaken = 0.0;
          _leavesPendingApproval = 0.0;
          _remainingLeaves = 0.0;
        }

        notifyListeners();
        return _lwps!;
      } else {
        print('Failed to load leave details: ${response.statusCode}');
        throw Exception('Failed to load leave details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leave details: $e');
      throw Exception('Failed to load leave details');
    }
  }

  //post leaveapplication details
  Future<void> postLeaveType(
      String leaveType,
      String fromDate,
      String toDate,
      int halfDay,
      String halfDayDate,
      int totalLeaveDays,
      String description,
      String leaveApprover,
      int followViaEmail,
      String postingDate,
      BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final name = prefs.getString('fullName') ?? '';
      final email = prefs.getString('usr') ?? '';

      final String employeeId = prefs.getString('employeeid') ?? '';
      final url =
          Uri.parse('${Config.baseUrl}/api/resource/Leave%20Application');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "cookie": token ?? '',
        },
        body: jsonEncode(<String, dynamic>{
          'employee': employeeId,
          "employee_name": name,
          "owner": email,
          'leave_type': leaveType,
          "from_date": fromDate,
          "to_date": toDate,
          "half_day": halfDay,
          "half_day_date": halfDayDate,
          "total_leave_days": totalLeaveDays,
          "description": description,
          "leave_approver": leaveApprover,
          "follow_via_email": followViaEmail,
          "posting_date": postingDate
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaveListview(),
            ));
        print('Success: $jsonResponse');
      } else {
        print('Failed to post leave type: ${response.statusCode}');
        throw Exception('Failed to post leave type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting leave type: $e');
      throw Exception('Failed to post leave type');
    }
  }

  //no of day of leave
  int calculateTotalLeaveDays() {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays + 1;
    }
    return 0;
  }

  //fetch leave application details
  List<Map<String, dynamic>> _leaveApplications = [];

  List<Map<String, dynamic>> get leaveApplications => _leaveApplications;

  Future<void> fetchLeaveApplications(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      // final String employeeId = prefs.getString('employeeid') ?? '';
      final url = Uri.parse(
          '${Config.baseUrl}/api/resource/Leave%20Application?fields=["*"]&order_by=posting_date%20desc');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _leaveApplications =
            List<Map<String, dynamic>>.from(jsonResponse['data']);
        final leaveNames =
            _leaveApplications.map((leave) => leave['name'] as String).toList();
        await prefs.setStringList('leaveApplicationNames', leaveNames);

        notifyListeners();
      } else {
        print('Failed to load leave applications: ${response.statusCode}');
        _showErrorSnackBar(context,
            'Failed to load leave applications: ${response.statusCode}');
        throw Exception(
            'Failed to load leave applications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leave applications: $e');
      throw Exception('Failed to load leave applications');
    }
  }

  //error handling
  void _showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => fetchLeaveApplications(context), // Retry the API call
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //delete leave application
  Future<void> deleteRecord(String recordId, BuildContext context) async {
    final String baseUrl =
        '${Config.baseUrl}/api/resource/Leave%20Application/$recordId';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'cookie': '$token',
        },
      );

      if (response.statusCode == 200) {
        print('Record deleted successfully');
      } else {
        print('Failed to delete record: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool _isTextFieldInteracted = false;

  bool get isTextFieldInteracted => _isTextFieldInteracted;

  void setTextFieldInteracted(bool value) {
    _isTextFieldInteracted = value;
    notifyListeners();
  }

  //update leave application
  Future<void> updateLeaveApplication(
      {required String leaveApplicationId,
      required String leaveType,
      required String fromDate,
      required String toDate,
      required int halfDay,
      required String halfDayDate,
      required String description,
      required String postingDate,
      required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("cookie");
    final url = Uri.parse(
        '${Config.baseUrl}/api/resource/Leave%20Application/$leaveApplicationId');

    final Map<String, dynamic> data = {
      'leave_type': leaveType,
      'from_date': fromDate,
      'to_date': toDate,
      'half_day': halfDay,
      'half_day_date': halfDayDate,
      'description': description,
      'posting_date': postingDate,
    };

    final headers = {
      'Content-Type': 'application/json',
      'cookie': '$token',
    };

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: custom_text(
              text: 'Successfully Updated',
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
            builder: (context) => const LeaveListview(),
          ));
      notifyListeners();
      print('Leave Application updated successfully');
    } else {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: custom_text(
              text: 'Cannot Updated',
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
      print('Failed to update Leave Application: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

//mathod to clear values
  void clearValues() {
    _leaveType = null;
    _startDate = null;
    _endDate = null;
    _isHalfDay = false;
    _halfDayDate = null;
    reasonController.clear();
    dateValidationError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clearValues();
    super.dispose();
  }
}
