import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/widgets/cust_elevated_button.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_modalbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimesheetFormscreen extends StatelessWidget {
  TimesheetFormscreen({
    super.key,
  });

  final TextEditingController _endOfDayReviewController =
      TextEditingController();

  final TextEditingController _tomorrowPlanController = TextEditingController();

  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<TimesheetController>(context);
    provider.loadSharedPrefs();
    final timeLogs = provider.timeLogs;
    final timesheetName = provider.timesheetName;

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            provider.resetSavedStatus();
            await provider.fetchTimesheetDetails();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: SizedBox(
                width: screenWidth * 0.2,
                child: Image.asset('assets/images/efeone Logo.png'),
              ),
              actions: [
                provider.isPosted // Check if saved
                    ? CustomElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.blueGrey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                title: const custom_text(
                                  text: 'Confirm Submit',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                content: const custom_text(
                                  text:
                                      'Do you really want to submit this item?',
                                  fontSize: 16,
                                  color: Colors.white70,
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
                        label: "Submit")
                    : CustomElevatedButton(
                        onPressed: () {
                          provider.toggleSaved();
                          final postingDate = DateTime.now().toIso8601String();
                          final formattedNotes = timeLogs!
                              .map((log) =>
                                  "${log['description']} (${log['project']})")
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                  (entry) => "${entry.key + 1}. ${entry.value}")
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
                        label: "Save")
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
                        _buildInfoBox(provider.empname.toString(),
                            fontSize: 17),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Date"),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dateController.text.isNotEmpty
                                      ? _dateController.text
                                      : 'Select Date',
                                  style: TextStyle(
                                    color: _dateController.text.isNotEmpty
                                        ? Colors.black
                                        : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.calendar_today,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Timesheet Logs"),
                        const SizedBox(height: 10),
                        _buildTimeLogsTable(context),
                        const SizedBox(
                          height: 3,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.8,
                                  ),
                                  child: TimesheetRowBottomSheet(
                                    timeLog: const {},
                                    selectedDate: _dateController.text,
                                  ),
                                );
                              },
                            );
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
                        _buildSectionTitle("Tomorrows Plan"),
                        const SizedBox(height: 10),
                        _buildTextField(_tomorrowPlanController),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Loading Indicator
        if (provider.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
          ),
      ],
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
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildTimeLogsTable(BuildContext context) {
    // final timeLogs = Provider.of<TimesheetController>(context).timeLogs;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DataTable(
            columnSpacing: 40,
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => const Color.fromRGBO(238, 238, 238, 1),
            ),
            columns: const [
              DataColumn(
                label: SizedBox(
                  width: 40,
                  child: Text('No', textAlign: TextAlign.center),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100,
                  child: Text('Activity Type', textAlign: TextAlign.center),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 80,
                  child: Text('From Time', textAlign: TextAlign.center),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 60,
                  child: Text('Hours', textAlign: TextAlign.center),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100,
                  child: Text('Project', textAlign: TextAlign.center),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 50,
                  child: Icon(Icons.settings),
                ),
              ),
            ],
            rows: _buildTimeLogRows(context),
          )),
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
          _buildTableCell(formatFromTime(timeLog['from_time'] ?? '')),
          _buildTableCell(timeLog['hours'].toString()),
          _buildTableCell(timeLog['project'] ?? ''),
          DataCell(
            IconButton(
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: TimesheetRowBottomSheet(
                        timeLog: timeLog,
                        selectedDate: _dateController.text,
                      ),
                    );
                  },
                ).then((updatedLog) {
                  if (updatedLog != null) {
                    provider.updateTimeLog(timeLog['index'], updatedLog);
                  }
                });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      _dateController.text = formattedDate;
    }
  }
}
