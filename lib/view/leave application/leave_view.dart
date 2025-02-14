import 'package:efeone_mobile/controllers/leave.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:provider/provider.dart';

class LeaveView extends StatefulWidget {
  final String reason;
  final String fromDate;
  final String toDate;
  final int isHalfDay;
  final String halfDayDate;
  final String leaveType;
  final String status;
  final double totalLeaveDays;
  final String id;
  final String employee;
  final String approver;

  const LeaveView(
      {super.key,
      required this.reason,
      required this.fromDate,
      required this.toDate,
      required this.isHalfDay,
      required this.halfDayDate,
      required this.leaveType,
      required this.status, // Added status
      required this.totalLeaveDays,
      required this.id,
      required this.employee,
      required this.approver});

  @override
  State<LeaveView> createState() => _LeaveViewState();
}

class _LeaveViewState extends State<LeaveView> {
  bool showDropdown = true;
  @override
  Widget build(BuildContext context) {
    bool isHalfDayChecked = widget.isHalfDay == 1;
    final String leaveApprover = widget.approver;
    final provider = Provider.of<LeaveRequestProvider>(context, listen: false);
    provider.loadSharedPrefs();

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRichText('Employee', widget.employee),
                const SizedBox(height: 16),
                _buildRichText("Leave id", widget.id),
                const SizedBox(height: 16),
                _buildRichText("From Date", formatDate(widget.fromDate)),
                const SizedBox(height: 16),
                _buildRichText("To Date", formatDate(widget.toDate)),
                const SizedBox(height: 16),
                _buildRichText(
                    "Total Leave Days", widget.totalLeaveDays.toString()),

                if (isHalfDayChecked) ...[
                  const SizedBox(height: 12),
                  _buildRichText("Half Day Date", widget.halfDayDate),
                ],
                const SizedBox(height: 12),
                _buildRichText("Leave Type", widget.leaveType),
                const SizedBox(height: 12),
                _buildRichText("Reason", widget.reason),
                const SizedBox(height: 20),
                // Status Container
                leaveApprover == provider.usr
                    ? (showDropdown
                        ? _buildStatusDropdown(context)
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: widget.status == "Approved"
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: custom_text(
                                text: widget.status,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.status == "Approved"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ))
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: widget.status == "Approved"
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: custom_text(
                            text: widget.status,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.status == "Approved"
                                ? Colors.green
                                : Colors.orange,
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

  Widget _buildStatusDropdown(BuildContext context) {
    final provider = Provider.of<LeaveRequestProvider>(context);
    final String leaveId = widget.id;
    final String currentStatus = widget.status;
    final List<String> statuses = ['Open', 'Approved', 'Rejected'];

    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newStatus) {
        if (newStatus != null) {
          context.read<LeaveRequestProvider>().setStatus(newStatus);
          provider.updateLeavestatus(
              leaveApplicationId: leaveId, status: newStatus, context: context);
          setState(() {
            showDropdown = false;
          });
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

  Widget _buildRichText(String label, String value,
      {FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: custom_text(
            text: "$label  :",
            fontSize: 16,
            fontWeight: fontWeight,
            color: primaryColor,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
