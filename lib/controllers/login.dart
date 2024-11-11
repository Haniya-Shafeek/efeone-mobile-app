import 'dart:convert';
import 'package:efeone_mobile/view/home_view.dart';
import 'package:efeone_mobile/utilities/config.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginController extends ChangeNotifier {
  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  set isPasswordVisible(bool value) {
    _isPasswordVisible = value;
    notifyListeners();
  }

  Future<void> postLoginDetails(
      String email, String password, BuildContext context) async {
    final url = Uri.parse('${Config.baseUrl}/api/method/login');
    print(url);
    final Map<String, dynamic> loginDetails = {
      "usr": email,
      "pwd": password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginDetails),
      );

      if (response.statusCode == 200) {
        String rawCookie = response.headers['set-cookie'] ?? '';
        int index = rawCookie.indexOf(';');
        var cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("cookie", cookie);

        final Map<String, dynamic> responseBody = json.decode(response.body);
        final fullName = responseBody['full_name'] ?? '';

        await prefs.setString('fullName', fullName);
        await prefs.setString('usr', email);
        await prefs.setString('pwd', password);

        final loginPref = await SharedPreferences.getInstance();
        loginPref.setBool("islogin", true);
        await getempid();
        await storeLoginTime();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Homepage(),
            ),
            (route) => false);
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 147, 140),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: custom_text(
                text: 'Invalid Login',
                color: Colors.red,
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
      }
    } catch (e) {
      print("exception occured : $e");
    }
  }

 Future<void> getempid() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("cookie");
  final userId = prefs.getString("usr");

  String url = '${Config.baseUrl}/api/resource/Employee?filters=[["user_id", "=", "$userId"]]&fields=["name", "image"]';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "cookie": token ?? '',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('data')) {
        List<dynamic> data = responseBody['data'];
        if (data.isNotEmpty) {
          String employeeId = data[0]['name'];
          String imgUrl = '';
          if (data[0]['image'] != null) {
            imgUrl = Config.baseUrl + data[0]['image'];
          }

          // Save image URL and employee ID locally to avoid refetching
          await prefs.setString('employeeid', employeeId);
          await prefs.setString('img_url', imgUrl);
          notifyListeners();
        }
      }
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      print('Image access restricted. Skipping repeated requests.');
      // Optional: Store a flag to indicate restricted access if needed
    } else {
      print('Request failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

//function to check internet connection
  void connectioncheck(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                ),
                custom_text(
                  text: 'No internet connection',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }
  }

  Future<void> storeLoginTime() async {
    final loginpref = await SharedPreferences.getInstance();
    final loginTime = DateTime.now().toIso8601String();
    loginpref.setString("loginTime", loginTime);
  }
}
