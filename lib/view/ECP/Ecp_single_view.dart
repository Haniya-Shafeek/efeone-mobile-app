import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckinPermissionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ecpItem;

  const CheckinPermissionDetailScreen({super.key, required this.ecpItem});

  @override
  State<CheckinPermissionDetailScreen> createState() =>
      _CheckinPermissionDetailScreenState();
}

class _CheckinPermissionDetailScreenState
    extends State<CheckinPermissionDetailScreen> {
  bool showDropdown = true;

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    provider.loadSharedPrefs();
    print("owner   ${widget.ecpItem['owner']}");

    final String employee = widget.ecpItem['employee_name'] ?? 'N/A';
    final String name = widget.ecpItem['name'] ?? 'N/A';
    final String date = formatDate(widget.ecpItem['date'] ?? 'N/A');
    final String logType = widget.ecpItem['log_type'] ?? 'N/A';
    final String arrivalTime = widget.ecpItem['arrival_time'] ?? 'N/A';
    final String leavingTime = widget.ecpItem['leaving_time'] ?? 'N/A';
    final String reason = widget.ecpItem['reason'] ?? 'N/A';
    final String? isReportsToUser = widget.ecpItem['reports_to_user'];
    final status = widget.ecpItem['workflow_state'] ?? 'N/A';

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Employee:", employee),
              _buildDetailRow("Ecp Id:", name),
              _buildDetailRow("Date:", date),
              _buildDetailRow("Log Type:", logType),
              if (logType.trim().toLowerCase() == 'in')
                _buildDetailRow("Arrival Time:", arrivalTime),
              if (logType.trim().toLowerCase() == 'out')
                _buildDetailRow("Leaving Time:", leavingTime),
              _buildDetailRow("Reason:", reason),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Center(
                child: isReportsToUser == provider.logmail
                    ? (showDropdown
                        ? _buildStatusDropdown(context)
                        : _buildStatusButton(context, status))
                    : _buildStatusButton(context, status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: custom_text(
              text: title,
              fontWeight: FontWeight.normal,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          Expanded(
            flex: 2,
            child: custom_text(
              text: value,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
        ],
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

  Widget _buildStatusDropdown(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    final String ecpId = widget.ecpItem['name'] ?? 'N/A';
    final String currentStatus = widget.ecpItem['workflow_state'] ?? 'N/A';
    final List<String> statuses = ['Pending', 'Approved', 'Rejected'];

    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newStatus) {
        if (newStatus != null) {
          context.read<CheckinPermissionProvider>().setStatus(newStatus);
          provider.updateEcpstatus(
              ecpApplicationId: ecpId, status: newStatus, context: context);
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
}
