import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashcontroller extends ChangeNotifier {
  Future<void> checklogin(BuildContext context) async {
    final loginpref = await SharedPreferences.getInstance();
    bool isLogin = loginpref.getBool("islogin") ?? false;
    String? token = loginpref.getString("cookie");
    String? loginTimeString = loginpref.getString("loginTime");
    if (loginTimeString != null) {
      DateTime loginTime = DateTime.parse(loginTimeString);
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(loginTime);

      if (difference.inHours >= 12) {
        // More than 24 hours have passed, navigate to the login screen
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }
    }

    if (isLogin && token != null && token.isNotEmpty) {
      // Check if 24 hours have passed since the last login

      // Less than 24 hours have passed, navigate to the home screen
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      // Token is not present or the user is not logged in, navigate to the login screen
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  bool _isScaled = false;
  bool get isScaled => _isScaled;

  void startAnimation() {
    _isScaled = true;
    notifyListeners();
  }
  // Future<void> getlogin(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final email = prefs.getString("usr");
  //   final password = prefs.getString("pwd");
  //   final url = Uri.parse('${Config.baseUrl}/api/method/login');
  //   final Map<String, dynamic> loginDetails = {
  //     "usr": email,
  //     "pwd": password,
  //   };
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(loginDetails),
  //   );
  //   if (response.statusCode == 200) {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const Homepage(),
  //         ),
  //         (route) => false);
  //   } else {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => Loginscreen(),
  //         ),
  //         (route) => false);
  //   }
  // }
}
