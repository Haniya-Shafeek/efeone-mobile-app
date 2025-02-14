import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/customdropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimesheetRowupdateviewSheet extends StatefulWidget {
  final Map<String, dynamic>? timeLog;
  final String timesheetId;
  final String? startdate;

  const TimesheetRowupdateviewSheet(
      {super.key, this.timeLog, required this.timesheetId, this.startdate});

  @override
  State<TimesheetRowupdateviewSheet> createState() => _TsEditviewState();
}

class _TsEditviewState extends State<TimesheetRowupdateviewSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _startdate;
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
      _startdate = DateTime.parse(widget.startdate!);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.05;

    return WillPopScope(
      onWillPop: () async {
        provider.fetchSingleTimesheetDetails(widget.timesheetId);
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Project Name'),
                const SizedBox(height: 10),
                _buildDropdown(provider.projects, _selectedProject, (value) {
                  setState(() {
                    _selectedProject = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildSectionTitle('Activity Type'),
                const SizedBox(height: 10),
                _buildDropdown(provider.activitytype, _selectedCategory,
                    (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildDatePicker(
                  'Date',
                  _startdate,
                ),
                const SizedBox(height: 20),
                _buildTimePicker(
                    'Start Time', _selectedStartTime, _pickStartTime),
                const SizedBox(height: 20),
                _buildTimePicker('End Time', _selectedEndTime, _pickEndTime),
                const SizedBox(height: 20),
                _buildSectionTitle('Work Description'),
                const SizedBox(height: 10),
                _buildTextField(
                    _descriptionController, 'Enter work description'),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: () async {
                      saveTimesheet();
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
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return custom_text(
      text: title,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey[900],
      fontSize: 16,
    );
  }

  Widget _buildDropdown(
      List<dynamic> items, String? selectedValue, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MyDropdownFormField(
        selectedValue: selectedValue,
        items: items.map((item) => item['name'] as String).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String title, DateTime? selectedDate) {
    return _buildPickerContainer(
      title: selectedDate == null
          ? 'Select $title'
          : DateFormat.yMMMd().format(selectedDate),
      icon: Icons.calendar_today,
    );
  }

  Widget _buildTimePicker(
      String title, TimeOfDay? selectedTime, Function(BuildContext) onTap) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: _buildPickerContainer(
        title: selectedTime == null
            ? 'Select $title'
            : selectedTime.format(context),
        icon: Icons.access_time,
      ),
    );
  }

  Widget _buildPickerContainer(
      {required String title, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          custom_text(text: title, color: Colors.black),
          Icon(icon, color: Colors.blueGrey[900]),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
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
      _startdate!.year,
      _startdate!.month,
      _startdate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final toTime = DateTime(
      _startdate!.year,
      _startdate!.month,
      _startdate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    final timesheet = await provider.fetchTimesheetData(widget.timesheetId);
    final List<Map<String, dynamic>> existingTimeLogs =
        List<Map<String, dynamic>>.from(timesheet['time_logs'] ?? []);

    int newIdx = 1;
    if (existingTimeLogs.isNotEmpty) {
      newIdx = existingTimeLogs
              .map<int>((log) => int.tryParse(log['idx'].toString()) ?? 0)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    String newDescription =
        _descriptionController.text.trim(); // Trim leading/trailing spaces
    if (widget.timeLog != null) {
      final existingDescription = widget.timeLog?['description']?.trim() ?? '';
      if (newDescription != existingDescription) {
        newDescription = '$existingDescription\n$newDescription'.trim();
      }
    }

    Map<String, dynamic> newTimeLog = {
      "idx": widget.timeLog?['idx'] ?? newIdx.toString(),
      "name": widget.timeLog?['name'] ?? '',
      "activity_type": _selectedCategory,
      "description": newDescription,
      "from_time": fromTime.toIso8601String(),
      "to_time": toTime.toIso8601String(),
      "completed": _isCompleted ? 1 : 0,
      "project": _selectedProject,
    };

    if (widget.timeLog == null) {
      existingTimeLogs.add(newTimeLog);
    } else {
      existingTimeLogs
          .removeWhere((log) => log['idx'] == widget.timeLog!['idx']);
      existingTimeLogs.add(newTimeLog);
    }

    // Generate the formatted note with each log entry on a new line
    final note = existingTimeLogs.asMap().entries.map((entry) {
      int index = entry.key + 1; // to start numbering from 1
      String description = entry.value['description'];
      String project = entry.value['project'];
      return "$index. $description ($project)";
    }).join('<br>'); // Ensure each entry appears on a new line

    final updatedData = {
      "time_logs": existingTimeLogs,
      "note": note, // Note section
    };

    await provider.updateTimesheet(widget.timesheetId, updatedData, context);
    provider.isPosted = false;
    Navigator.pop(context);
    provider.fetchSingleTimesheetDetails(widget.timesheetId);
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
}

// Function to show modal bottom sheet
void showTimesheetModal(
    BuildContext context, Map<String, dynamic>? timeLog, String timesheetId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => TimesheetRowupdateviewSheet(
      timeLog: timeLog,
      timesheetId: timesheetId,
    ),
  );
}
