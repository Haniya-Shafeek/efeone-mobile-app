import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Ecpeditview extends StatefulWidget {
  final String date;
  final String logtype;
  final String reason;
  final String arrivalTime;
  final String leavingTime;
  final String ecpid;

  const Ecpeditview({
    super.key,
    required this.arrivalTime,
    required this.date,
    required this.leavingTime,
    required this.logtype,
    required this.ecpid,
    required this.reason,
  });

  @override
  State<Ecpeditview> createState() => _EcpeditviewState();
}

class _EcpeditviewState extends State<Ecpeditview> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _reasonController;
  late String _logType;
  late String _id;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.date);
    _timeController = TextEditingController(
      text: widget.logtype == 'IN' ? widget.arrivalTime : widget.leavingTime,
    );
    _reasonController = TextEditingController(text: widget.reason);
    _logType = widget.logtype;
    _id = widget.ecpid;
  }

  Future<void> _pickDate(
      TextEditingController controller, BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: tertiaryColor,
              surface: primaryColor,
              onSurface: primaryColor,
            ),
            dialogBackgroundColor: tertiaryColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime(
      TextEditingController controller, BuildContext context) async {
    TimeOfDay initialTime;
    try {
      final parsedTime = DateFormat.jm().parse(controller.text);
      initialTime = TimeOfDay.fromDateTime(parsedTime);
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: tertiaryColor,
              surface: primaryColor,
              onSurface: primaryColor,
            ),
            dialogBackgroundColor: tertiaryColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final time =
            DateFormat.Hms().format(DateTimeField.convertTimeOfDay(picked));
        controller.text = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Name'),
                _buildInfoContainer(_id),
                const SizedBox(height: 16),
                _buildSectionTitle('Date'),
                GestureDetector(
                  onTap: () {
                    _pickDate(_dateController, context);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Log Type'),
                DropdownButtonFormField<String>(
                  value: _logType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  items: ["IN", 'OUT'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _logType = newValue!;
                      _timeController.text = _logType == 'IN'
                          ? widget.arrivalTime
                          : widget.leavingTime;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionTitle(_logType == 'IN'
                    ? 'Expected Arrival Time'
                    : 'Expected Leaving Time'),
                GestureDetector(
                  onTap: () {
                    _pickTime(_timeController, context);
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Reason'),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () {
                        final logType = _logType;
                        final date = _dateController.text;
                        final reason = _reasonController.text;
                        final time = _timeController.text;
                        provider.updateEcp(
                          ecpApplicationId: _id,
                          logType: logType,
                          date: date,
                          arrivalTime:
                              logType == 'IN' ? time : widget.arrivalTime,
                          leavingTime:
                              logType == 'OUT' ? time : widget.leavingTime,
                          reason: reason,
                          context: context,
                        );
                      },
                      child: const custom_text(
                          text: 'Update', color: Colors.white),
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

  Widget _buildSectionTitle(String title) {
    return custom_text(text: title, fontWeight: FontWeight.bold, fontSize: 16);
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: custom_text(text: text, fontSize: 15),
    );
  }
}

class DateTimeField {
  static DateTime convertTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}
