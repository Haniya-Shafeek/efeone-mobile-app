import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/leave.dart';

class LeaveEditView extends StatefulWidget {
  final String reason;
  final String fromDate;
  final String toDate;
  final int isHalfDay;
  final String halfDayDate;
  final String leaveType;
  final double totalLeaveDays;
  final String id;
  final String status;
  final String approver;
  final String owner;

  const LeaveEditView(
      {super.key,
      required this.reason,
      required this.fromDate,
      required this.toDate,
      required this.isHalfDay,
      required this.halfDayDate,
      required this.leaveType,
      required this.totalLeaveDays,
      required this.id,
      required this.approver,
      required this.owner,
      required this.status});

  @override
  _LeaveEditViewState createState() => _LeaveEditViewState();
}

class _LeaveEditViewState extends State<LeaveEditView> {
  late TextEditingController _reasonController;
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  late TextEditingController _halfDayDateController;
  late TextEditingController _leaveTypeController;
  late TextEditingController _totalLeaveDaysController;
  late String _id;
  late bool _isHalfDay;
  bool _isFieldClicked = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);
    controller.loadSharedPrefs();
    _reasonController = TextEditingController(text: widget.reason);
    _fromDateController = TextEditingController(text: widget.fromDate);
    _toDateController = TextEditingController(text: widget.toDate);
    _halfDayDateController = TextEditingController(text: widget.halfDayDate);
    _leaveTypeController = TextEditingController(text: widget.leaveType);
    _totalLeaveDaysController =
        TextEditingController(text: widget.totalLeaveDays.toString());

    _isHalfDay = widget.isHalfDay == 1;
    _id = widget.id;
    _selectedStatus = widget.status;
    print("Employee reached LeaveEditView - Current Status: $_selectedStatus");
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _halfDayDateController.dispose();
    _leaveTypeController.dispose();
    _totalLeaveDaysController.dispose();
    super.dispose();
  }

  void _onFieldClicked() {
    setState(() {
      _isFieldClicked = true;
    });
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
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[900]!,
              onPrimary: Colors.white,
              surface: Colors.blueGrey[900]!,
              onSurface: Colors.blueGrey[900]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _isFieldClicked = true;
      });
      _validateDates();
    }
  }

  String? _validationError;
  String? _fromDateError;
  String? _toDateError;
  String? _halfDayDateError;
  void _validateDates() {
    final fromDate = DateTime.tryParse(_fromDateController.text);
    final toDate = DateTime.tryParse(_toDateController.text);
    final halfDayDate = DateTime.tryParse(_halfDayDateController.text);

    setState(() {
      _fromDateError = null;
      _toDateError = null;
      _halfDayDateError = null;

      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        _fromDateError = 'Start date cannot be after end date';
        _toDateError = 'End date cannot be before start date';
      } else if (_isHalfDay &&
          halfDayDate != null &&
          (fromDate == null ||
              toDate == null ||
              halfDayDate.isBefore(fromDate) ||
              halfDayDate.isAfter(toDate))) {
        _halfDayDateError =
            'Half-day date must be within the start and end dates';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);
    bool isApprover =
        widget.approver.toLowerCase() == controller.usr!.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 90,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          if (widget.status.toLowerCase() == 'open')
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        title: const custom_text(
                          text: 'Confirm Deletion',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        content: const Text(
                          'Are you sure you want to delete this item?',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              controller.deleteRecord(_id, context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => const LeaveListview(),
                              //     ));
                            },
                            child: const custom_text(
                                text: 'Delete', color: Colors.redAccent),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: custom_text(
                                text: 'Cancel', color: Colors.blueGrey[900]),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabeledContainer(
                      'Employee ID', controller.empid.toString()),
                  _buildLabeledContainer(
                      'Employee Name', controller.empname.toString()),
                  const SizedBox(
                    height: 10,
                  ),
                  const custom_text(
                    text: 'From Date',
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fromDateController,
                    readOnly: true, // Prevents manual input
                    onTap: () {
                      _onFieldClicked();
                      _pickDate(_fromDateController, context);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(top: 3, bottom: 3, left: 20),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: maincolor,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  if (_fromDateError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _fromDateError!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const custom_text(
                    text: 'To Date',
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _toDateController,
                    readOnly: true, // Prevents manual input
                    onTap: () {
                      _onFieldClicked();
                      _pickDate(_toDateController, context);
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
                  if (_toDateError != null) ...[
                    const SizedBox(height: 8),
                    custom_text(
                        text: _toDateError!,
                        color: Colors.redAccent,
                        fontSize: 14),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isHalfDay,
                        onChanged: (bool? value) {
                          setState(() {
                            _isHalfDay = value ?? false;
                            _isFieldClicked = true;
                          });
                        },
                      ),
                      const custom_text(
                        text: 'Half Day',
                        fontWeight: FontWeight.bold,
                        color: maincolor,
                      ),
                    ],
                  ),
                  if (_isHalfDay) ...[
                    const SizedBox(height: 16),
                    const custom_text(
                      text: 'Half Day Date',
                      fontWeight: FontWeight.bold,
                      color: maincolor,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _halfDayDateController,
                      readOnly: true, // Prevents manual input
                      onTap: () {
                        _onFieldClicked();
                        _pickDate(_halfDayDateController, context);
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(top: 3, bottom: 3, left: 20),
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: maincolor,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    if (_halfDayDateError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _halfDayDateError!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 14),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  const custom_text(
                    text: 'Leave Type',
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.leaveTypes.contains(widget.leaveType)
                        ? widget.leaveType
                        : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      // Background color for the dropdown field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            15.0), // Rounded border for the field
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 2, 51, 91), // Border color
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: controller.leaveTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: custom_text(
                          text: type,
                          color: maincolor,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        controller.setLeaveType(newValue);
                        _isFieldClicked = true;
                      });
                    },
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    elevation: 5,
                    menuMaxHeight: 400,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 25),
                  if (isApprover && widget.status.toLowerCase() == 'open')
                    _selectedStatus == null
                        ? _buildApproverDropdown(
                            controller) // Show dropdown initially
                        : _buildStatusButton()
                  else if (_isFieldClicked &&
                      widget.status.toLowerCase() == "open" &&
                      widget.owner.toLowerCase() ==
                          controller.usr!.toLowerCase()) ...[
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          onPressed: () {
                            if (_validationError == null) {
                              final leaveType = widget.leaveType;
                              final fromDate = _fromDateController.text;
                              final toDate = _toDateController.text;
                              final halfDay = _isHalfDay ? 1 : 0;
                              final halfDayDate =
                                  _isHalfDay ? _halfDayDateController.text : '';
                              final reason = _reasonController.text;
                              final postingDate =
                                  DateTime.now().toIso8601String();

                              controller.updateLeaveApplication(
                                leaveApplicationId: _id,
                                leaveType: leaveType,
                                fromDate: fromDate,
                                toDate: toDate,
                                halfDay: halfDay,
                                halfDayDate: halfDayDate,
                                description: reason,
                                postingDate: postingDate,
                                context: context,
                              );
                            }
                          },
                          child: const custom_text(
                              text: 'Update', color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown for approver (Only shown initially)
  Widget _buildApproverDropdown(LeaveRequestProvider controller) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Approve Leave',
        border: OutlineInputBorder(),
      ),
      value: null, // Initially null, must be selected
      items: ['Approved', 'Rejected', 'Cancelled','Open']
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue; // Update UI to show button
          });
          controller.updateLeavestatus(
              leaveApplicationId: widget.id,
              status: newValue,
              context: context);
        }
      },
    );
  }

  // Button showing final selected status
  Widget _buildStatusButton() {
    return ElevatedButton(
      onPressed: null, // Disabled button after approval
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedStatus == "Approved" ? Colors.green : Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      child: custom_text(
        text: _selectedStatus ?? '',
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLabeledContainer(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 51, 91)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(value, style: const TextStyle(color: maincolor)),
            ),
          ),
        ],
      ),
    );
  }
}
