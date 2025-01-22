import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/widgets/cust_elevated_button.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/customdropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimesheetRowupdateview extends StatefulWidget {
  final Map<String, dynamic>? timeLog;
  final String timesheetId;

  const TimesheetRowupdateview(
      {super.key, this.timeLog, required this.timesheetId});

  @override
  State<TimesheetRowupdateview> createState() => _TsEditviewState();
}

class _TsEditviewState extends State<TimesheetRowupdateview> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedCategory;
  String? _name;
  int? _index;
  String? _selectedProject;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.timeLog != null) {
      final timeLog = widget.timeLog!;
      _index = timeLog["idx"];
      _name = timeLog['name'];
      _descriptionController.text = timeLog['description'] ?? '';
      _selectedDate = timeLog['from_time'] != null
          ? DateTime.tryParse(timeLog['from_time']) ?? DateTime.now()
          : DateTime.now();
      _selectedStartTime = TimeOfDay.fromDateTime(_selectedDate!);
      _selectedEndTime = timeLog['to_time'] != null
          ? TimeOfDay.fromDateTime(
              DateTime.tryParse(timeLog['to_time']) ?? DateTime.now())
          : TimeOfDay.now();
      _selectedCategory = timeLog['activity_type'] ?? '';
      _selectedProject = timeLog['project'] ?? '';
      _isCompleted = (timeLog['completed'] ?? 0) == 1;
    }
    final provider = Provider.of<TimesheetController>(context, listen: false);
    provider.fetchprojectType();
    provider.fetchActivitytype();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    // print(widget.timesheetId);
    // print(widget.timeLog!['idx']);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.05;

    return WillPopScope(
      onWillPop: () async {
        provider.fetchSingleTimesheetDetails(widget.timesheetId);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: screenWidth * 0.2,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
          actions: [
            CustomElevatedButton(
                onPressed: () {
                  print("elevated clicked");
                  saveTimesheet();
                },
                label: "Save"),

            IconButton(
                onPressed: () {
                  _confirmDelete(provider);
                },
                icon: const Icon(
                  Icons.delete,
                  size: 27,
                  color: Colors.red,
                ))
            // TextButton(
            //   onPressed: () async {
            //     saveTimesheet();
            //   },
            //   child: const custom_text(
            //     text: 'Save',
            //     fontWeight: FontWeight.bold,
            //     color: primaryColor,
            //   ),
            // ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Project Name'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyDropdownFormField(
                      selectedValue: _selectedProject,
                      items: provider.projects
                          .map((project) => project['name'] as String)
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProject = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Activity Type'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyDropdownFormField(
                      selectedValue: _selectedCategory,
                      items: provider.activitytype
                          .map((category) => category['name'] as String)
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Date'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: padding),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          custom_text(
                            text: _selectedDate == null
                                ? 'Select Date'
                                : DateFormat.yMMMd().format(_selectedDate!),
                            color: Colors.black,
                          ),
                          Icon(Icons.calendar_today,
                              color: Colors.blueGrey[900]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Start Time'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickStartTime(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: padding),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.black),
                          const SizedBox(width: 10),
                          custom_text(
                            text: _selectedStartTime == null
                                ? 'Select Start Time'
                                : _selectedStartTime!.format(context),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('End Time'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickEndTime(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: padding),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blueGrey[900]),
                          const SizedBox(width: 10),
                          custom_text(
                            text: _selectedEndTime == null
                                ? 'Select End Time'
                                : _selectedEndTime!.format(context),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Work Description'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter work description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Mark as Completed'),
                  const SizedBox(height: 10),
                  Switch(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to pick a start time
  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  // Method to pick an end time
  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return custom_text(
      text: title,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey[900],
      fontSize: 16,
    );
  }

  void _confirmDelete(TimesheetController provider) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Time Log'),
            content: const Text(
                'Doyou want to delete this row? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const custom_text(
                  text: "Cancel",
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Perform deletion and close dialog
                  await provider.deleteTimesheetRow(
                      widget.timesheetId, _name!, context);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const custom_text(
                  text: "Delete",
                  color: Colors.red,
                ),
              ),
            ],
          );
        });
  }

  // void saveTimesheet() async {
  //   print("called");
  //   final provider = Provider.of<TimesheetController>(context, listen: false);

  //   // Ensure all required fields are filled
  //   if (_selectedDate == null ||
  //       _selectedStartTime == null ||
  //       _selectedEndTime == null ||
  //       _selectedCategory == null ||
  //       _selectedProject == null) {
  //     _showErrorDialog("Please fill in all required fields.");
  //     return;
  //   }

  //   final fromTime = DateTime(
  //     _selectedDate!.year,
  //     _selectedDate!.month,
  //     _selectedDate!.day,
  //     _selectedStartTime!.hour,
  //     _selectedStartTime!.minute,
  //   );

  //   final toTime = DateTime(
  //     _selectedDate!.year,
  //     _selectedDate!.month,
  //     _selectedDate!.day,
  //     _selectedEndTime!.hour,
  //     _selectedEndTime!.minute,
  //   );

  //   // Check if widget.timeLog is null
  //   if (widget.timeLog == null) {
  //     print("Error: widget.timeLog is null");
  //     _showErrorDialog("Time log data is not available.");
  //     return;
  //   }

  //   // Get the current time log
  //   final currentLog = widget.timeLog;

  //   // Check if the currentLog exists and is not empty
  //   if (currentLog == null) {
  //     print("Error: currentLog is empty or null");
  //     _showErrorDialog("Invalid time log.");
  //     return;
  //   }

  //   // Safely get the time_logs list from widget.timeLog
  //   List<dynamic> timeLogs = widget.timeLog?['time_logs'] ?? [];

  //   // Debug: Print timeLogs and currentLog idx
  //   print("Time Logs List: $timeLogs");
  //   print("widget.timeLog['idx']: ${widget.timeLog!['idx']}");

  //   // Find the index of the log to update
  //   int logIndex =
  //       timeLogs.indexWhere((log) => log['idx'] == widget.timeLog!['idx']);
  //   if (logIndex == -1) {
  //     print("Error: Log with the specified idx not found.");
  //     _showErrorDialog("Time log with the specified idx not found.");
  //     return;
  //   }

  //   // Update the log with the same idx
  //   timeLogs[logIndex] = {
  //     ...timeLogs[logIndex], // Keep existing fields
  //     'activity_type': _selectedCategory,
  //     'description': _descriptionController.text.trim(),
  //     'from_time': fromTime.toIso8601String(),
  //     'to_time': toTime.toIso8601String(),
  //     'completed': _isCompleted ? 1 : 0,
  //     'project': _selectedProject,
  //   };

  //   // Prepare the updated data
  //   final updatedData = {
  //     "time_logs": timeLogs, // Update the whole list with the modified log
  //   };

  //   print('Updated Data: $updatedData');

  //   // Call the provider to update the timesheet on the server
  //   bool success = await provider.updateTimesheet(
  //       widget.timesheetId, updatedData, context);

  //   // Check if the update was successful
  //   if (success) {
  //     if (mounted) {
  //       Navigator.pop(context); // Close the current screen on success
  //     }
  //   } else {
  //     _showErrorDialog("Failed to save timesheet.");
  //   }
  // }
  void saveTimesheet() async {
    print("called");
    final provider = Provider.of<TimesheetController>(context, listen: false);
    final fromTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final toTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );
    final timeLogData = {
      'description': _descriptionController.text,
      'date': _selectedDate?.toIso8601String(),
      'activity_type': _selectedCategory,
      'from_time': fromTime.toIso8601String(),
      'to_time': toTime.toIso8601String(),
      'project': _selectedProject,
      'completed': _isCompleted ? 1 : 0,
      'idx': _index,
    };
    provider.updateTimesheetRow(
        widget.timesheetId, _name!, timeLogData, context);
  }
}
