import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSnackbar({
    required BuildContext context,
    required String message,
    required Color bgColor,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
    Color textColor = Colors.white,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: margin,
      ),
    );
  }
}
