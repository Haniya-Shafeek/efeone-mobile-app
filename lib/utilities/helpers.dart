//Method to formate date
import 'package:intl/intl.dart';

String formatDate(String? date) {
  if (date == null || date.isEmpty) return 'N/A';
  final DateTime parsedDate = DateTime.parse(date);
  return DateFormat('MMM d, y').format(parsedDate); // Format the date
}

//Method to formate hour
String roundHours(double hours) {
  return hours.toStringAsFixed(2); // Show up to 2 decimal places
}
