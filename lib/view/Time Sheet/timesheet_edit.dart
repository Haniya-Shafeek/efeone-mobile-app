import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_rowupdate.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimesheetEditViewScreen extends StatefulWidget {
  final String? timesheetId;
  final String? review;
  final String? plan;

  const TimesheetEditViewScreen(
      {super.key, this.timesheetId, this.review, this.plan});

  @override
  State<TimesheetEditViewScreen> createState() =>
      _TimesheetEditViewScreenState();
}

class _TimesheetEditViewScreenState extends State<TimesheetEditViewScreen> {
  late TextEditingController endOfTheReviewController;
  late TextEditingController tomorrowplanController;

  @override
  void initState() {
    super.initState();
    endOfTheReviewController = TextEditingController(text: widget.review ?? '');
    tomorrowplanController = TextEditingController(text: widget.plan ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        provider.resetSavedStatus();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
          actions: [
            provider.isSaved
                ? TextButton(
                    onPressed: () {
                      provider.submitTimesheet(widget.timesheetId!, context);
                    },
                    child: const Text('submit'),
                  )
                : TextButton(
                    onPressed: () {
                      provider.submitTimesheet(widget.timesheetId!, context);
                    },
                    child:
                        const custom_text(text: 'Submit', color: primaryColor),
                  )
          ],
        ),
        body: FutureBuilder<void>(
          future: provider.fetchSingleTimesheetDetails(widget.timesheetId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor,));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Employee ID"),
                      const SizedBox(height: 8),
                      _buildInfoBox(
                          provider.timesheetDetail?['employee'] ?? "N/A"),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Employee Name"),
                      const SizedBox(height: 8),
                      _buildInfoBox(
                          provider.timesheetDetail?['employee_name'] ?? "N/A"),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Posting Date"),
                      const SizedBox(height: 8),
                      _buildInfoBox(
                          provider.timesheetDetail?['posting_date'] ?? "N/A"),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Time Log Details"),
                      const SizedBox(height: 8),
                      _buildTimeLogTable(
                          provider.timesheetDetail?['time_logs'] ?? [],
                          context),
                      ElevatedButton(
                        onPressed: () {
                          provider.addEmptyLogtimelog(context);
                        },
                        child: const custom_text(
                            text: 'Add Row', color: primaryColor),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("End Of The Review"),
                      const SizedBox(height: 10),
                      _buildTextField(endOfTheReviewController),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Tomorrow's Plan"),
                      const SizedBox(height: 10),
                      _buildTextField(tomorrowplanController),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return custom_text(
      text: title,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: Colors.blueGrey[900],
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildInfoBox(String text, {double fontSize = 14}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: custom_text(text: text, fontSize: fontSize),
    );
  }

  Widget _buildTimeLogTable(List<dynamic>? logs, BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromRGBO(238, 238, 238, 1), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          columnSpacing: 12,
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => const Color.fromRGBO(238, 238, 238, 1),
          ),
          columns: const [
            DataColumn(label: Text('Activity')),
            DataColumn(label: Text('From Time')),
            DataColumn(label: Text('To Time')),
            DataColumn(label: Text('Hours')),
            DataColumn(label: Text('Project')),
            DataColumn(label: Icon(Icons.settings)),
          ],
          rows: logs?.map((log) {
                return DataRow(
                  cells: [
                    DataCell(Text(log['activity_type']?.toString() ?? "N/A")),
                    DataCell(Text(log['from_time']?.toString() ?? "N/A")),
                    DataCell(Text(log['to_time']?.toString() ?? "N/A")),
                    DataCell(Text(roundHours(log['hours'] ?? 0).toString())),
                    DataCell(Text(log['project']?.toString() ?? "N/A")),
                    DataCell(
                      IconButton(
                        onPressed: () async {
                          final updatedLog = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimesheetRowupdateview(
                                timeLog: log,
                                timesheetId: widget.timesheetId!,
                              ),
                            ),
                          );

                          if (updatedLog != null) {
                            setState(() {
                              int logIndex = logs.indexOf(log);
                              logs[logIndex] = updatedLog;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  ],
                );
              }).toList() ??
              [],
        ),
      ),
    );
  }
}
