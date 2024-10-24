import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ResetPasswordScreen extends StatefulWidget {
  final String token; // token or email received from the reset link

  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('https://jalebi.efeone.com/api/method/reset_password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Password reset successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully.'),
        ),
      );
      Navigator.pop(context);
    } else {
      print('Failed to reset password. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reset password.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text ==
                    _confirmPasswordController.text) {
                  resetPassword(widget.token, _passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match.'),
                    ),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
