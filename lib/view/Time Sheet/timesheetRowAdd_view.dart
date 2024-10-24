import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetForm_view.dart';
import 'package:efeone_mobile/widgets/customdropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimesheetRowaddview extends StatefulWidget {
  final Map<String, dynamic>? timeLog;
  const TimesheetRowaddview({super.key, this.timeLog});

  @override
  State<TimesheetRowaddview> createState() => _TsEditviewState();
}

class _TsEditviewState extends State<TimesheetRowaddview> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedCategory;
  String? _selectedProject;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    if (widget.timeLog != null) {
      final timeLog = widget.timeLog!;
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    provider.fetchprojectType();
    provider.fetchActivitytype();

    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2, // Adjusted width
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_selectedDate != null &&
                  _selectedStartTime != null &&
                  _selectedEndTime != null &&
                  _selectedCategory != null &&
                  _selectedProject != null &&
                  _descriptionController.text.isNotEmpty) {
                if (_selectedStartTime == _selectedEndTime) {
                  _showErrorDialog(
                      'Start time and end time cannot be the same.');
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

                if (fromTime.isAfter(toTime)) {
                  _showErrorDialog('Start time must be before end time.');
                  return;
                }
                if (widget.timeLog != null) {
                  final indexToRemove = provider.timeLogs!.indexWhere(
                      (log) => log['index'] == widget.timeLog!['index']);
                  if (indexToRemove != -1) {
                    provider.timeLogs!.removeAt(indexToRemove);
                  }
                }

                final duration = toTime.difference(fromTime);
                final hours = duration.inHours;
                final minutes = duration.inMinutes % 60;
                final formattedDuration = '${hours}h ${minutes}m';
                final description = _descriptionController.text;
                final prjctname = _selectedProject!;

                provider.addtimeLog({
                  'index': (provider.timeLogs!.isNotEmpty
                      ? provider.timeLogs!.last['index'] + 1
                      : 1),
                  "activity_type": _selectedCategory!,
                  "from_time": fromTime.toIso8601String(),
                  "to_time": toTime.toIso8601String(),
                  "description": description,
                  "completed": _isCompleted ? 1 : 0,
                  "project": prjctname,
                  "hours": formattedDuration
                });

                _descriptionController.clear();
                _selectedDate = null;
                _selectedStartTime = null;
                _selectedEndTime = null;
                _selectedCategory = null;
                _selectedProject = null;
                _isCompleted = false;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Time Log Added Successfully!')),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimesheetFormscreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: const Text(
              'Save',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
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
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat.yMMMd().format(_selectedDate!),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
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
                        Text(
                          _selectedStartTime == null
                              ? 'Select Start Time'
                              : _selectedStartTime!.format(context),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
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
                        Text(
                          _selectedEndTime == null
                              ? 'Select End Time'
                              : _selectedEndTime!.format(context),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
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
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter work description',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value ?? false;
                        });
                      },
                    ),
                    const Text('Completed'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color
          title: const Text(
            'Error',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final initialTime = _selectedStartTime ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null && pickedTime != initialTime) {
      setState(() {
        _selectedStartTime = pickedTime;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final initialTime = _selectedEndTime ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null && pickedTime != initialTime) {
      setState(() {
        _selectedEndTime = pickedTime;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
