import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
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
  int? _index;
  String? _selectedProject;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.timeLog != null) {
      final timeLog = widget.timeLog!;
      _index = timeLog["idx"];
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

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              saveTimesheet();
            },
            child: const custom_text(
              text: 'Save',
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
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
                MyDropdownFormField(
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
                const SizedBox(height: 20),
                _buildSectionTitle('Activity Type'),
                const SizedBox(height: 10),
                MyDropdownFormField(
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
                const SizedBox(height: 20),
                _buildSectionTitle('Date'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: padding),
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
                        Icon(Icons.calendar_today, color: Colors.blueGrey[900]),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: padding),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: padding),
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

  void saveTimesheet() async {
    final provider = Provider.of<TimesheetController>(context, listen: false);

    if (_selectedDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null ||
        _selectedCategory == null ||
        _selectedProject == null) {
      _showErrorDialog("Please fill in all required fields.");
      return;
    }

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
    final updatedData = {
      "time_logs": [
        {
         'idx':widget.timeLog!['idx'],
          "name": widget.timeLog!["name"],
          "activity_type": _selectedCategory,
          "description": _descriptionController.text,
          "from_time": fromTime.toIso8601String(),
          "to_time": toTime.toIso8601String(),
          "completed": _isCompleted ? 1 : 0,
          "project": _selectedProject,
        }
      ]
    };

    // Debugging output to verify data
    print('Updated Data: $updatedData');

    bool success = await provider.updateTimesheet(
        widget.timesheetId, updatedData, context);

    if (success) {
      Navigator.pop(context);
    } else {
      _showErrorDialog("Failed to save timesheet.");
    }
  }
}
