import 'dart:convert';
import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/widgets/cust_snackbar.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckinPermissionProvider with ChangeNotifier {
  TimeOfDay? _arrivalTime;
  TimeOfDay? _leavingTime;
  DateTime? _selectedDate;
  String? _selectedLogType;
  String? _ecpName;
  String? _empid;
  String? _logmail;
  List<Map<String, dynamic>> _ecp = [];
  String? _empname;
  String? _reportsToUser;
  String? _dateValidationError;
  List<Map<String, dynamic>> _checkinList = [];
  String _status = 'Pending';

  List<Map<String, dynamic>> get checkinData => _checkinList;
  List<Map<String, dynamic>> get ecp => _ecp;
  TimeOfDay? get selectedarrivalTime => _arrivalTime;
  String? get dateValidationError => _dateValidationError;
  TimeOfDay? get selectedLeavingTime => _leavingTime;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedLogType => _selectedLogType;
  String? get empid => _empid;
  String? get logmail => _logmail;
  String? get ecpName => _ecpName;
  String? get empname => _empname;
  String? get reportsToUser => _reportsToUser;
  String get status => _status;

  final formKey = GlobalKey<FormState>();
  TextEditingController reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  //Method to get valuess on shared preferenvce
  Future<void> loadSharedPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _empid = pref.getString('employeeid') ?? '';
    _empname = pref.getString("fullName") ?? "";
    _logmail = pref.getString('usr') ?? '';
    notifyListeners();
  }

  bool loading = false;

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  //Method to select date
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    if (picked != null) {
      _selectedDate = picked;
      notifyListeners();
    }
  }

  //Method to select arrival time
  void selectarrivalTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      _arrivalTime = picked;
      notifyListeners();
    }
  }

  //Method to select leaving time
  void selectLeavingTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      _leavingTime = picked;
      notifyListeners();
    }
  }

//Method to select log type
  void selectLogType(String logType) {
    _selectedLogType = logType;
    notifyListeners();
  }

  //Method to submit ecp
  Future<void> submitCheckinPermission({
    required String empId,
    required String date,
    required String logType,
    required String arrivalTime,
    required String leavingTime,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final email = prefs.getString('usr') ?? '';
      final Map<String, dynamic> payload = {
        'employee': empId,
        'date': _selectedDate?.toIso8601String(),
        'log_type': _selectedLogType,
        'arrival_time': formatTimeOfDay(_arrivalTime),
        "leaving_time": formatTimeOfDay(_leavingTime),
        'reason': reason,
        'reports_to_user': _reportsToUser,
        "owner": email
      };

      final response = await http.post(
        Uri.parse(
            "${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        CustomSnackbar.showSnackbar(
            context: context,
            message: "ECP Posted Successfully",
            bgColor: Colors.green);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckinPermissionListScreen(),
            ));
        print('Check-in permission submitted successfully');
      } else {
        print('Failed to submit check-in permission: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setLoading(false);
    }
  }

  //get checkin details
  Future<void> fetchCheckin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          '${Config.baseUrl}/api/resource/Employee%20Checkin?fields=["*"]';
      print(url);
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/api/resource/Employee%20Checkin?fields=["*"]&order_by=time%20desc&limit_page_length=1000'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          _checkinList = List<Map<String, dynamic>>.from(jsonData['data']);
          notifyListeners();
        } else {
          print('Invalid response format');
        }
      } else {
        print('Failed to fetch check-in details: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  //get ECP details
  Future<void> fetchCheckinPermissionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("cookie");
      final url =
          '${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission?fields=["*"]&order_by=creation%20desc';
      print(url);
      final response = await http.get(
        Uri.parse(
            '${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission?fields=["*"]&order_by=date%20desc'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          _ecp = List<Map<String, dynamic>>.from(jsonData['data']);
        } else {
          print('Invalid response format');
        }
      } else {
        print('Failed to F check-in permission details: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  // Method to formatting time
  String? formatTimeOfDay(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
        0, // seconds
        0, // milliseconds
        0, // microseconds
      );
      final formattedTime = dateTime.toIso8601String().split('T')[1];
      return formattedTime;
    }
    return null;
  }

//Method to delete ECP
  Future<void> deleteECP(String recordId) async {
    final String baseUrl =
        '${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission/$recordId';

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

  //Method to update ecp
  Future<void> updateEcp(
      {required String ecpApplicationId,
      required String logType,
      required String date,
      required String arrivalTime,
      required String leavingTime,
      required String reason,
      required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("cookie");
    final url = Uri.parse(
        '${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission/$ecpApplicationId');

    final Map<String, dynamic> data = {
      'log_type': logType,
      'date': date,
      "arrival_time": arrivalTime,
      "leaving_time": leavingTime,
      'reason': reason,
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
      CustomSnackbar.showSnackbar(
          context: context,
          message: "ECP Updated Successfully",
          bgColor: Colors.green);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckinPermissionListScreen(),
          ));
      notifyListeners();
      print('Successfully Ecp Updated');
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

  //Method to update status
  Future<void> updateEcpstatus(
      {required String ecpApplicationId,
      required String status,
      required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("cookie");
    final url = Uri.parse(
        '${Config.baseUrl}/api/resource/Employee%20Checkin%20Permission/$ecpApplicationId');

    final Map<String, dynamic> data = {'workflow_state': status};

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
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: custom_text(
              text: 'Successfully Status Updated',
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
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const CheckinPermissionListScreen(),
      //     ));
      notifyListeners();
      print('Ecp Status updated successfully');
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

  //Method to change the status

  void setStatus(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  //method to delete Employee Checkin
  Future<void> deleteCheckin(String checkinId, BuildContext context) async {
    final String baseUrl =
        '${Config.baseUrl}/api/resource/Employee%20Checkin/$checkinId';
    print(baseUrl);

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
        CustomSnackbar.showSnackbar(
            context: context,
            message: "Checkin deleted Successfully",
            bgColor: Colors.red);
        print('Record deleted successfully');
        await fetchCheckin();
        notifyListeners();
      } else {
        print('Failed to delete record: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

//method to clear fields
  void clearValues() {
    _arrivalTime = null;
    _leavingTime = null;
    _selectedDate = null;
    _selectedLogType = null;
    reasonController.clear();
    notifyListeners();
  }
}
