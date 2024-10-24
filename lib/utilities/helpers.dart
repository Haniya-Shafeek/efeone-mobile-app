//Method to formate date
import 'package:intl/intl.dart';
String formatDate(String? date) {
  if (date == null || date.isEmpty) return 'N/A';
  final DateTime parsedDate = DateTime.parse(date);
  return DateFormat('MMM d, y').format(parsedDate); // Format the date
}
//Method to formate hour
int roundHours(dynamic hours) {
    if (hours is num) {
      return hours.round();
    }
    return 0;
  }