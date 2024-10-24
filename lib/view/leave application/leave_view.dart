import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:efeone_mobile/utilities/helpers.dart';

class LeaveView extends StatelessWidget {
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
      required this.employee});

  @override
  Widget build(BuildContext context) {
    bool isHalfDayChecked = isHalfDay == 1;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 90,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
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
                _buildRichText('Employee', employee),
                const SizedBox(height: 16),
                _buildRichText("Leave id", id),
                const SizedBox(height: 16),
                _buildRichText("From Date", formatDate(fromDate)),
                const SizedBox(height: 16),
                _buildRichText("To Date", formatDate(toDate)),
                const SizedBox(height: 16),
                _buildRichText("Total Leave Days", totalLeaveDays.toString()),

                if (isHalfDayChecked) ...[
                  const SizedBox(height: 12),
                  _buildRichText("Half Day Date", halfDayDate),
                ],
                const SizedBox(height: 12),
                _buildRichText("Leave Type", leaveType),
                const SizedBox(height: 12),
                _buildRichText("Reason", reason),
                const SizedBox(height: 20),
                // Status Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: status == "Approved"
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: custom_text(
                    text:  status,
                    
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            status == "Approved" ? Colors.green : Colors.orange,
                     
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

  Widget _buildRichText(String label, String value,
      {FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: custom_text(
           text: "$label:",
           
              fontSize: 16,
              fontWeight: fontWeight,
              color: Colors.black54,
           
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
