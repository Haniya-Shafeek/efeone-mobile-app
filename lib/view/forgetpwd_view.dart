import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  Future<void> sendResetLink(String email) async {
    final url =
        Uri.parse('https://jalebi.efeone.com/api/method/forgot_password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'usr': email}),
    );

    if (response.statusCode == 200) {
      print('Password reset link sent successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent. Check your email.'),
        ),
      );
      Navigator.pop(context);
    } else {
      print('Failed to send reset link. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send reset link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.1), // Adjust top spacing
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.045),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.04,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text;
                    sendResetLink(email);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    child: Text(
                      'Send Reset Link',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
