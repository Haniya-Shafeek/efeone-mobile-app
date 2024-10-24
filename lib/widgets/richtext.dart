// rich_text_helper.dart
import 'package:flutter/material.dart';

class RichTextHelper {
  static Widget buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label : ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
