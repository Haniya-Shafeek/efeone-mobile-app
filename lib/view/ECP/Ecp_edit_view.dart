import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Ecpeditview extends StatefulWidget {
  final String employee;
  final String empname;
  final String date;
  final String logtype;
  final String reason;
  final String arrivalTime;
  final String leavingTime;
  final String ecpid;
  final String status;
  final String approver;
  final String owner;

  const Ecpeditview(
      {super.key,
      required this.empname,
      required this.employee,
      required this.arrivalTime,
      required this.date,
      required this.leavingTime,
      required this.logtype,
      required this.ecpid,
      required this.reason,
      required this.owner,
      required this.approver,
      required this.status});

  @override
  State<Ecpeditview> createState() => _EcpeditviewState();
}

class _EcpeditviewState extends State<Ecpeditview> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _reasonController;
  late String _logType;
  late String _emp;
  late String _empname;
  late String _id;
  bool _isFieldClicked = false;
  String? _selectedStatus;

  String _formatTime(String timeString) {
    try {
      final time = DateFormat("HH:mm").parse(timeString);
      return DateFormat("hh.mm a").format(time);
    } catch (e) {
      return timeString;
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.date);
    _timeController = TextEditingController(
      text: (widget.logtype == 'IN' && widget.arrivalTime.isNotEmpty)
          ? _formatTime(widget.arrivalTime)
          : (widget.leavingTime.isNotEmpty
              ? _formatTime(widget.leavingTime)
              : ''),
    );
    _reasonController = TextEditingController(text: widget.reason);
    _logType = widget.logtype.isNotEmpty ? widget.logtype : 'IN';
    _id = widget.ecpid.isNotEmpty ? widget.ecpid : '';
    _emp = widget.employee.isNotEmpty ? widget.employee : '';
    _empname = widget.empname.isNotEmpty ? widget.empname : '';
    _selectedStatus = widget.status;
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
    );

    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final formattedTime = DateFormat.jm().format(
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
        );
        controller.text = formattedTime;
      });
    }
  }

  void _onFieldClicked() {
    setState(() {
      _isFieldClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    bool isreportsto =
        widget.approver.toLowerCase() == provider.logmail!.toLowerCase();
    provider.loadSharedPrefs();

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          if (widget.status.toLowerCase() == 'pending' &&
              widget.owner.toLowerCase() == provider.logmail!.toLowerCase())
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.blueGrey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          title: const Text(
                            'Confirm Deletion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          content: const Text(
                            'Do you really want to delete this item?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await provider.deleteECP(widget.ecpid);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CheckinPermissionListScreen(),
                                    ));
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outlined,
                    color: Colors.red,
                  )),
            )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabeledContainer('Employee ID', _emp),
                  _buildLabeledContainer('Employee Name', _empname),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Date'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dateController,
                    readOnly: true, // Prevents manual input
                    onTap: () {
                      _onFieldClicked();
                      _pickDate(_dateController, context);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(top: 1, bottom: 1, left: 20),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: maincolor,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Log Type'),
                  const SizedBox(height: 8),
                  _buildDropdownInput(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(_logType == 'IN'
                      ? 'Expected Arrival Time'
                      : 'Expected Leaving Time'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _timeController,
                    readOnly: true, // Prevents manual input
                    onTap: () {
                      _onFieldClicked();
                      _pickTime(_timeController, context);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(top: 1, bottom: 1, left: 20),
                      suffixIcon: const Icon(
                        Icons.alarm_outlined,
                        color: maincolor,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const custom_text(
                    text: 'Reason',
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                  const SizedBox(height: 8),
                  CustomField(
                    controller: _reasonController,
                    maxline: 4,
                    onTap: _onFieldClicked,
                  ),
                  const SizedBox(height: 15),
                  if (isreportsto && widget.status.toLowerCase() == 'pending')
                    _selectedStatus == null
                        ? _buildStatusDropdown(
                            context) // Show dropdown initially
                        : _buildStatusButton(context, widget.status)
                  else if (_isFieldClicked &&
                      widget.status.toLowerCase() == "pending" &&
                      widget.owner.toLowerCase() ==
                          provider.logmail!.toLowerCase())
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
                            final formattedTime = formatTime(time);
                            provider.updateEcp(
                              ecpApplicationId: _id,
                              logType: logType,
                              date: date,
                              arrivalTime: logType == 'IN'
                                  ? formattedTime
                                  : widget.arrivalTime,
                              leavingTime: logType == 'OUT'
                                  ? formattedTime
                                  : widget.leavingTime,
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
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String status) {
    final Color statusColor = _getStatusColor(status);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: statusColor,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.015,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: custom_text(
          text: status,
          color: tertiaryColor,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.045,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return custom_text(
      text: title,
      fontWeight: FontWeight.w600,
      color: maincolor,
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    final String ecpId = widget.ecpid;
    final String currentStatus = widget.status;
    final List<String> statuses = ['Pending', 'Approved', 'Rejected'];

    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newStatus) {
        if (newStatus != null) {
          context.read<CheckinPermissionProvider>().setStatus(newStatus);
          provider.updateEcpstatus(
              ecpApplicationId: ecpId, status: newStatus, context: context);
        }
      },
      items: statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green[400]!;
      case 'Open':
        return Colors.orange[400]!;
      case 'Rejected':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Widget _buildLabeledContainer(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: maincolor)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          border: InputBorder.none,
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdownInput() {
    return DropdownButtonFormField<String>(
      value: _logType,
      items: const [
        DropdownMenuItem(value: 'IN', child: Text('IN')),
        DropdownMenuItem(value: 'OUT', child: Text('OUT')),
      ],
      onChanged: (value) {
        setState(() {
          _logType = value!;
          _isFieldClicked = true;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15.0), // Rounded border for the field
          borderSide: const BorderSide(
            color: Colors.grey, // Border color
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
      dropdownColor: Colors.white,
      isExpanded: true,
      elevation: 5,
      menuMaxHeight: 400,
      borderRadius: BorderRadius.circular(15),
    );
  }

  String formatTime(String time) {
    final timeParsed = DateFormat("HH:mm").parse(time);
    return DateFormat("hh:mm a").format(timeParsed);
  }
}
