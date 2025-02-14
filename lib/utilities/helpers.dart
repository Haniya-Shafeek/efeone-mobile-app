//Method to formate date
import 'package:intl/intl.dart';

String formatDate(String? date) {
  if (date == null || date.trim().isEmpty) {
    return 'N/A';
  }
  try {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('MMM d, y').format(parsedDate);
  } catch (e) {
    return 'No Date';
  }
}

//Method to formate hour
String roundHours(double hours) {
  return hours.toStringAsFixed(2);
}

//chekin time format
String formatCheckinTime(String time) {
  DateTime parsedTime = DateTime.parse(time);
  return DateFormat('MMM d, yyyy   hh:mm a').format(parsedTime);
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm:ss:SSS').format(dateTime);
}
String formatDatefromTime(String? time) {
    if (time == null) return 'N/A';
    try {
      DateTime parsedTime = DateTime.parse(time);
      // Format the time in 12-hour format with AM/PM
      return DateFormat('MMM d,yyyy').format(parsedTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

String formatFromTime(String fromTime) {
  try {
    DateTime dateTime = DateTime.parse(fromTime);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  } catch (e) {
    // Handle invalid or null `from_time` gracefully
    return '';
  }
}
  // Convert the selected time to "HH:mm:ss" format
                        String formatTime(String inputTime) {
                          try {
                            // Parse the input time (e.g., "9:20") to a DateTime object
                            final parsedTime =
                                DateFormat('HH:mm').parse(inputTime);

                            // Format the time to "HH:mm:ss"
                            return DateFormat('HH:mm:ss').format(parsedTime);
                          } catch (e) {
                            // Handle parsing errors or return a default time
                            print('Error formatting time: $e');
                            return '00:00:00';
                          }
                        }
