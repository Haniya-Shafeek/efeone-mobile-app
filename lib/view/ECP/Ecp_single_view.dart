import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckinPermissionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ecpItem;

  const CheckinPermissionDetailScreen({super.key, required this.ecpItem});

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    provider.loadSharedPrefs();

    final String employee = ecpItem['employee_name'] ?? 'N/A';
    final String name = ecpItem['name'] ?? 'N/A';
    final String date = formatDate(ecpItem['date'] ?? 'N/A');
    final String logType = ecpItem['log_type'] ?? 'N/A';
    final String arrivalTime = ecpItem['arrival_time'] ?? 'N/A';
    final String leavingTime = ecpItem['leaving_time'] ?? 'N/A';
    final String reason = ecpItem['reason'] ?? 'N/A';
    final String? isReportsToUser = ecpItem['reports_to_user'];
    // final String status = ecpItem['workflow_state'] ?? 'N/A';
    // final String owner = ecpItem['owner'] ?? 'N/A';

    final double textSize = MediaQuery.of(context).size.width * 0.04;
    final double fieldPadding = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/efeone Logo.png',
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: ListView(
          children: [
            _buildSectionTitle("Employee", textSize),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTextField(employee, fieldPadding),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildSectionTitle("Ecp Id", textSize),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTextField(name, fieldPadding),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildSectionTitle("Date", textSize),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTextField(date, fieldPadding),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildSectionTitle("Log Type", textSize),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTextField(logType, fieldPadding),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            if (logType.trim().toLowerCase() == 'in') ...[
              _buildSectionTitle("Arrival Time", textSize),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              _buildTextField(arrivalTime, fieldPadding),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            ],
            if (logType.trim().toLowerCase() == 'out') ...[
              _buildSectionTitle("Leaving Time", textSize),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              _buildTextField(leavingTime, fieldPadding),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            ],
            _buildSectionTitle("Reason", textSize),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            _buildTextField(reason, fieldPadding, maxLines: 3),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            if (isReportsToUser == provider.logmail)
              Center(child: _buildStatusDropdown(context))
            else
              Center(child: _buildStatusButton(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double textSize) {
    return custom_text(
        text: title, fontWeight: FontWeight.bold, fontSize: textSize);
  }

  Widget _buildTextField(String text, double fieldPadding, {int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(fieldPadding),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
      readOnly: true,
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    final status = ecpItem['workflow_state'] ?? 'N/A';
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
          text: 'Status: $status',
          color: tertiaryColor,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.045,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    final String ecpId = ecpItem['name'] ?? 'N/A';
    final String currentStatus = ecpItem['workflow_state'] ?? 'N/A';
    final List<String> statuses = ['Open', 'Pending', 'Approved', 'Rejected'];

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
        return Colors.green;
      case 'Open':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
