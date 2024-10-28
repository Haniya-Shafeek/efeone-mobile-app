import 'dart:convert';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/view/login_view.dart';

class Profilecontroller extends ChangeNotifier {
  String _fullname = '';
  String _empid = '';
  String _email = '';
  String _imgurl = "";
  String _dob = '';
  String _designation = '';
  String _dateofjoining = '';

  String get fullname => _fullname;
  String get imgurl => _imgurl;
  String get empid => _empid;
  String get email => _email;
  String get dob => _dob;
  String get designation => _designation;
  String get dateofjoining => _dateofjoining;

  Future<void> getempdetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("cookie");
    final userId = prefs.getString("usr");
    print("userid $userId");
    _imgurl = prefs.getString('img_url') ?? '';

    String url =
        '${Config.baseUrl}/api/resource/Employee?fields=["*"]&filters=[["user_id", "=", "$userId"]]';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "cookie": token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print(response.body);
        List<dynamic> data = responseBody['data'];

        if (data.isNotEmpty) {
          // Safely extract each field with default value if null
          final name = data[0]['employee_name'] ?? 'No name found';
          final id = data[0]['name'] ?? 'N/A';
          final empemail = data[0]['personal_email'] ?? 'N/A';
          final empdob = data[0]['date_of_birth'] ?? 'N/A';
          final empdsgntion = data[0]['designation'] ?? 'N/A';
          final doj = data[0]['date_of_joining'] ?? 'N/A';

          // Format dates if not null
          String formattedDob = empdob != 'N/A' ? formatDate(empdob) : 'N/A';
          String formattedDoj = doj != 'N/A' ? formatDate(doj) : 'N/A';

          // Update shared preferences
          await prefs.setString('user_name', name);
          await prefs.setString('id', id);
          await prefs.setString('email', empemail);
          await prefs.setString('dob', empdob);
          await prefs.setString('designation', empdsgntion);
          await prefs.setString('dateofjoing', doj);

          // Update local variables
          _fullname = name;
          _empid = id;
          _email = empemail;
          _dob = formattedDob;
          _designation = empdsgntion;
          _dateofjoining = formattedDoj;

          notifyListeners();
        } else {
          print('No data found for the given user ID.');
        }
      } else {
        print(
            'Failed to load profile details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile details: $e');
    }
  }

  //Method to logout
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie');

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/method/logout'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      prefs.setBool('islogin', false);
      prefs.remove('usr');
      prefs.remove('pwd');
      prefs.remove('cookie');
      prefs.remove('employeeid');
      prefs.remove('log_time');
      prefs.remove('log_type');
      prefs.remove('img_url');
      prefs.remove('fullName');
      // Profile details
      prefs.remove('user_name');
      prefs.remove('cookie');
      prefs.remove('id');
      prefs.remove('email');
      prefs.remove('dob');
      prefs.remove('designation');
      prefs.remove('dateofjoing');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to logout'),
        ),
      );
    }
  }
}
