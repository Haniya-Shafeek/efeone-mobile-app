import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2, // Adjusted for responsiveness
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: provider.fetchTimesheetData(tsname),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return const SizedBox(); // Return an empty widget if data is not available
              }

              final data = snapshot.data!;
              final String status = data['status'] ?? '';
              if (status.toLowerCase() != 'draft') {
                return const SizedBox(); // Hide button if status is not "Draft"
              }

              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: TextButton(
                  child: const custom_text(
                    text: 'Edit',
                    color: Color.fromARGB(255, 2, 51, 91),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimesheetEditViewScreen(
                          timesheetId: tsname,
                          review: data['end_of_the_day_review'],
                          plan: data['tomorrows_plan'],
                          startdate: data['start_date'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: provider
            .fetchTimesheetData(tsname), // Call the method returning a Future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGreyPlaceholderCard(), // Placeholder for Timesheet Overview
                  const SizedBox(height: 16),
                  _buildGreyPlaceholderCard(
                      height: 150), // Placeholder for Time Logs
                  const SizedBox(height: 16),
                  _buildGreyPlaceholderCard(
                      height: 80), // Placeholder for End of Day Review
                  const SizedBox(height: 16),
                  _buildGreyPlaceholderCard(
                      height: 80), // Placeholder for Tomorrow's Plan
                ],
              ),
            );
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Log the error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found.'));
          }

          // Safely get the fetched data
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          // Extract necessary fields from the data
          final timeLogs = data['time_logs'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Build cards using the data extracted from the response
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
      color: Colors.blue[50],
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

  Widget _buildGreyPlaceholderCard({double height = 150}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTimeLogsCard(
      List<dynamic> timeLogs, double screenWidth, BuildContext context) {
    return Card(
      color: Colors.blue[50],
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(200), // Set fixed or flexible widths
                  1: FixedColumnWidth(150),
                  2: FixedColumnWidth(150),
                  3: FixedColumnWidth(100),
                  4: FixedColumnWidth(100),
                  5: FixedColumnWidth(80),
                },
                border: TableBorder.all(
                  color: Colors.grey,
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
        color: Colors.blue[50],
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
        _buildTableHeaderCell('Project'),
        _buildTableHeaderCell('Activity Type'),
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
        _buildTableCell(Text(log['project'] ?? 'No Project')),
        _buildTableCell(Text(log['activity_type'] ?? 'No Activity Type')),
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
    return DateFormat('hh:mm:ss a')
        .format(time); // 12-hour format with seconds and AM/PM
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
                provider.deleteTimesheet(tsname, context);
                Navigator.popUntil(
                  context,
                  (route) =>
                      route.isFirst || route.settings.name == '/timesheetList',
                ); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
