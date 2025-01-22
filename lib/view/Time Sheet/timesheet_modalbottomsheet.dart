import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/customdropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimesheetRowBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? timeLog;
  final String selectedDate;

  const TimesheetRowBottomSheet(
      {super.key, this.timeLog, required this.selectedDate});

  @override
  _TimesheetRowBottomSheetState createState() =>
      _TimesheetRowBottomSheetState();
}

class _TimesheetRowBottomSheetState extends State<TimesheetRowBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
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
    final provider = Provider.of<TimesheetController>(context, listen: false);
    if (provider.projects.isEmpty) provider.fetchprojectType();
    if (provider.activitytype.isEmpty) provider.fetchActivitytype();
  }

  @override
  Widget build(BuildContext context) {
    _dateController.text = widget.selectedDate;
    final provider = Provider.of<TimesheetController>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const custom_text(
                      text: "Add Row",
                      color: primaryColor,
                      fontSize: 22,
                    ),
                    IconButton(
                        onPressed: () {
                          _confirmDelete(provider);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Project Name'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MyDropdownFormField(
                  selectedValue: _selectedCategory,
                  items: provider.activitytype
                      .map((activity) => activity['name'] as String)
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Start Time'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickStartTime(context),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        _selectedStartTime == null
                            ? 'Select Start Time'
                            : _selectedStartTime!.format(context),
                        style: const TextStyle(color: Colors.black),
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
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blueGrey[900]),
                      const SizedBox(width: 10),
                      Text(
                        _selectedEndTime == null
                            ? 'Select End Time'
                            : _selectedEndTime!.format(context),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Work Description'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter work description',
                  ),
                  maxLines: 4,
                ),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    if (_selectedStartTime != null &&
                        _selectedEndTime != null &&
                        _selectedCategory != null &&
                        _selectedProject != null &&
                        _descriptionController.text.isNotEmpty) {
                      if (_selectedStartTime == _selectedEndTime) {
                        _showErrorDialog(
                            'Start time and end time cannot be the same.');
                        return;
                      }
                      final DateTime finalDate = widget.selectedDate != null
                          ? DateFormat('dd-MM-yyyy').parse(widget.selectedDate)
                          : DateTime.now();
                      final fromTime = DateTime(
                        finalDate.year,
                        finalDate.month,
                        finalDate.day,
                        _selectedStartTime!.hour,
                        _selectedStartTime!.minute,
                      );

                      final toTime = DateTime(
                        finalDate.year,
                        finalDate.month,
                        finalDate.day,
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
                        const SnackBar(
                            content: Text('Time Log Added Successfully!')),
                      );
                      Navigator.pop(context);

                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => TimesheetFormscreen(),
                      //   ),
                      // );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: const custom_text(
                    text: "Save",
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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

  void _confirmDelete(TimesheetController provider) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Time Log'),
            content: const Text(
                'Do you want to delete this Row? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const custom_text(
                  text: "Cancel",
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Perform deletion and close dialog
                  final indexToRemove = provider.timeLogs!.indexWhere(
                      (log) => log['index'] == widget.timeLog!['index']);
                  if (indexToRemove != -1) {
                    provider.timeLogs!.removeAt(indexToRemove);
                  }
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Return to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Time Log Deleted')),
                  );
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
    return custom_text(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700]);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss:SSS').format(dateTime);
  }
}
