import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetRowAdd_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimesheetFormscreen extends StatelessWidget {
  final TextEditingController _endOfDayReviewController =
      TextEditingController();
  final TextEditingController _tomorrowPlanController = TextEditingController();

  TimesheetFormscreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<TimesheetController>(context);
    provider.loadSharedPrefs();
    final timeLogs = provider.timeLogs;
    final timesheetName = provider.timesheetName;

    return WillPopScope(
      onWillPop: () async {
        provider.resetSavedStatus();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: screenWidth * 0.2,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
          actions: [
            provider.isSaved // Check if saved
                ? ElevatedButton(
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
                              'Confirm Submit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            content: const Text(
                              'Do you really want to submit this item?',
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
                                onPressed: () {
                                  provider.submitTimesheet(
                                      timesheetName!, context);
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.green,
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
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      provider.toggleSaved();
                      final postingDate = DateTime.now().toIso8601String();
                      final formattedNotes = timeLogs!
                          .map((log) =>
                              "${log['description']} (${log['project']})")
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) => "${entry.key + 1}. ${entry.value}")
                          .join('<br>'); // Use <br> for line breaks in HTML
                      provider.postTimesheet(
                        postingDate: postingDate,
                        note: formattedNotes,
                        eodReview: _endOfDayReviewController.text,
                        tmrwplan: _tomorrowPlanController.text,
                        timeLogs: timeLogs,
                        context: context,
                      );
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            provider.clearTimeLogs();
            return true;
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Employee Id"),
                    const SizedBox(height: 8),
                    _buildInfoBox(provider.empid.toString(), fontSize: 15),
                    const SizedBox(height: 16),
                    _buildSectionTitle("Employee Name"),
                    const SizedBox(height: 8),
                    _buildInfoBox(provider.empname.toString(), fontSize: 17),
                    const SizedBox(height: 16),
                    _buildSectionTitle("Date"),
                    const SizedBox(height: 8),
                    _buildInfoBox(provider.postingDate.toString(),
                        fontSize: 17),
                    const SizedBox(height: 16),
                    _buildSectionTitle("Timesheet Logs"),
                    const SizedBox(height: 10),
                    _buildTimeLogsTable(context),
                    ElevatedButton(
                      onPressed: () {
                        provider.addEmptyLog(context);
                      },
                      child: const Text(
                        'Add Row',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('End of the Day Review'),
                    const SizedBox(height: 10),
                    _buildTextField(_endOfDayReviewController),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Tomorrow's Plan"),
                    const SizedBox(height: 10),
                    _buildTextField(_tomorrowPlanController),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[900],
      ),
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
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
      ),
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

  Widget _buildTimeLogsTable(BuildContext context) {
    final timeLogs = Provider.of<TimesheetController>(context).timeLogs;
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
            DataColumn(
                label:
                    Expanded(child: Text('No', textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text('Activity Type', textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text('From Time', textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text('Hours', textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text('Project', textAlign: TextAlign.center))),
            DataColumn(label: Icon(Icons.settings))
          ],
          rows: timeLogs == null || timeLogs.isEmpty
              ? _buildEmptyRow(context)
              : _buildTimeLogRows(context),
        ),
      ),
    );
  }

  List<DataRow> _buildTimeLogRows(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    final timeLogs = Provider.of<TimesheetController>(context).timeLogs;
    return timeLogs!.map((timeLog) {
      return DataRow(
        cells: [
          _buildTableCell(timeLog['index'].toString()),
          _buildTableCell(timeLog['activity_type'] ?? ''),
          _buildTableCell(timeLog['from_time'] ?? ''),
          _buildTableCell(timeLog['hours'].toString()),
          _buildTableCell(timeLog['project'] ?? ''),
          DataCell(
            IconButton(
              onPressed: () async {
                // Navigate to the TimesheetRowaddview and wait for the updated time log
                final updatedLog = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimesheetRowaddview(timeLog: timeLog),
                  ),
                );

                // Check if an updated log is returned
                if (updatedLog != null) {
                  provider.updateTimeLog(timeLog['index'],
                      updatedLog); // Call the provider to update the log
                }
              },
              icon: const Icon(Icons.edit),
            ),
          ),
        ],
      );
    }).toList();
  }

  DataCell _buildTableCell(String value) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Center(
          child: Text(value),
        ),
      ),
    );
  }

  List<DataRow> _buildEmptyRow(BuildContext context) {
    return [
      DataRow(cells: [
        const DataCell(Text('1')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('0')),
        const DataCell(Text('')),
        DataCell(
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimesheetRowaddview(timeLog: {}),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.grey),
          ),
        ),
      ]),
    ];
  }
}
