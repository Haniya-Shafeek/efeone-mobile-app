import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/timesheet.dart';

class TimesheetDetailScreen extends StatelessWidget {
  final String tsname;

  const TimesheetDetailScreen({
    super.key,
    required this.tsname,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    provider.fetchTimesheetData(tsname);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2, // Adjusted for responsiveness
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          if (provider.timesheetData != null &&
              provider.timesheetData!['status'] ==
                  'Draft') // Check if status is 'draft'
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, provider);
              },
            ),
        ],
      ),
      body: Consumer<TimesheetController>(
        builder: (context, provider, child) {
          final data = provider.timesheetData;

          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final timeLogs = data['time_logs'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTimesheetOverviewCard(data),
                _buildTimeLogsCard(timeLogs, screenWidth, context),
                _buildReviewOrPlanCard(
                    'End of Day Review', data['end_of_the_day_review']),
                _buildReviewOrPlanCard(
                    "Tomorrow's Plan", data['tomorrows_plan']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimesheetOverviewCard(Map<String, dynamic> data) {
    final date = formatDate(data['start_date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const custom_text(
              text: 'Timesheet Overview',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Employee', data['employee_name'] ?? 'N/A'),
            _buildInfoRow('Name', data['name'] ?? 'N/A'),
            _buildInfoRow('Status', data['status'] ?? 'N/A'),
            _buildInfoRow('Date', date),
            _buildInfoRow(
                'Total Hours', '${roundHours(data['total_hours'])} Hr'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLogsCard(
      List<dynamic> timeLogs, double screenWidth, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const custom_text(
              text: 'Time Logs',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: {
                0: FlexColumnWidth(screenWidth < 600 ? 2 : 3),
                1: FlexColumnWidth(screenWidth < 600 ? 1.5 : 2),
                2: FlexColumnWidth(screenWidth < 600 ? 1.5 : 2),
                3: FlexColumnWidth(screenWidth < 600 ? 1 : 1.5),
              },
              border: TableBorder.all(
                color: Colors.blueGrey[200]!,
                style: BorderStyle.solid,
                width: 1,
              ),
              children: [
                _buildTableHeader(),
                ...timeLogs.map((log) {
                  return _buildTableRow(log, context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewOrPlanCard(String title, String? content) {
    if (content == null || content.isEmpty) {
      return const SizedBox
          .shrink(); // Return an empty widget when there's no content
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // Consistent margin
      child: Card(
        elevation: 4,
        child: SizedBox(
          width: double.infinity, // Use double.infinity for full width
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                custom_text(
                  text: title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                const SizedBox(height: 8),
                custom_text(
                    text: content, fontSize: 16, color: Colors.blueGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[800],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildTableHeaderCell('Description'),
        _buildTableHeaderCell('From Time'),
        _buildTableHeaderCell('To Time'),
        _buildTableHeaderCell('Hr'),
      ],
    );
  }

  Widget _buildTableHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> log, BuildContext context) {
    return TableRow(
      children: [
        _buildTableCell(Text(log['description'] ?? 'No Description')),
        _buildTableCell(Text(_formatTime(log['from_time']))),
        _buildTableCell(Text(_formatTime(log['to_time']))),
        _buildTableCell(Text('${roundHours(log['hours'])} hr')),
      ],
    );
  }

  Widget _buildTableCell(Widget content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: content,
    );
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    final time = DateTime.parse(dateTime);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, TimesheetController provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this timesheet?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                provider.deleteTimesheet(tsname);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const TimesheetListviewScreen(),
                )); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
