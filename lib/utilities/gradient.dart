import 'package:flutter/material.dart';

class TaskStatusHelper {
  static LinearGradient getGradient(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pending review':
        return const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'open':
        return const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'overdue':
        return const LinearGradient(
          colors: [Colors.red, Colors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
