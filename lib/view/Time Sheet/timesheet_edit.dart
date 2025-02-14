import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/rowupdate_modalsheet.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_rowupdate.dart';
import 'package:efeone_mobile/widgets/cust_elevated_button.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimesheetEditViewScreen extends StatefulWidget {
  final String? timesheetId;
  final String? review;
  final String? plan;
  final String? startdate;

  const TimesheetEditViewScreen(
      {super.key, this.timesheetId, this.review, this.plan, this.startdate});

  @override
  State<TimesheetEditViewScreen> createState() =>
      _TimesheetEditViewScreenState();
}

class _TimesheetEditViewScreenState extends State<TimesheetEditViewScreen> {
  late TextEditingController endOfTheReviewController;
  late TextEditingController tomorrowplanController;
  bool isLoading = true;
  bool isTextFieldEdited = false;

  Future<void> _saveTimesheet() async {
    final provider = Provider.of<TimesheetController>(context, listen: false);
    final data = {
      "end_of_the_day_review": endOfTheReviewController.text,
      "tomorrows_plan": tomorrowplanController.text,
    };
    await provider.updateTimesheet(widget.timesheetId!, data, context);
    setState(() {
      isTextFieldEdited = false;
      provider.isPosted = false;
    });

    await _fetchTimesheetDetails();
  }

  @override
  void initState() {
    super.initState();
    endOfTheReviewController = TextEditingController(text: widget.review ?? '');
    tomorrowplanController = TextEditingController(text: widget.plan ?? '');
    _fetchTimesheetDetails();
  }

  bool _isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final provider = Provider.of<TimesheetController>(context, listen: false);
      provider.fetchSingleTimesheetDetails(widget.timesheetId!);
      _isInitialized = true;
    }
  }

  Future<void> _fetchTimesheetDetails() async {
    final provider = Provider.of<TimesheetController>(context, listen: false);
    await provider.fetchSingleTimesheetDetails(widget.timesheetId!);
    final details = provider.timesheetDetail;
    if (details != null) {
      setState(() {
        endOfTheReviewController.text = details['end_of_the_day_review'] ?? '';
        tomorrowplanController.text = details['tomorrows_plan'] ?? '';
        isLoading = false;
      });
    }
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
            (provider.isPosted || isTextFieldEdited)
                ? CustomElevatedButton(
                    onPressed: () {
                      _saveTimesheet();
                      provider.toggleButton();
                    },
                    label: "Save")
                : CustomElevatedButton(
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
                              text: 'Do you really want to submit this item?',
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
                                      widget.timesheetId!, context);
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
                    label: "Submit"),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                // Show the delete confirmation dialog directly
                bool? confirmDelete =
                    await _showDeleteConfirmationDialog(context);
                if (confirmDelete == true) {
                  await provider.deleteTimesheet(widget.timesheetId!, context);
                  provider.fetchTimesheetDetails();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : SingleChildScrollView(
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
                      _buildSectionTitle("Date"),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            lastDate: DateTime.now(),
                          );

                          if (selectedDate != null) {
                            final formattedDate =
                                selectedDate.toIso8601String().split('T').first;
                            await provider.updateStartDate(
                                widget.timesheetId!, formattedDate, context);
                            setState(() {
                              provider.timesheetDetail?['start_date'] =
                                  formattedDate;
                            });
                          }
                        },
                        child: _buildInfoBox(
                            provider.timesheetDetail?['start_date']),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Time Log Details"),
                      const SizedBox(height: 8),
                      _buildTimeLogTable(
                          provider.timesheetDetail?['time_logs'] ?? [],
                          context),
                      ElevatedButton(
                        onPressed: () {
                          provider.addEmptyLogtimelog(context);
                          final emptyLog =
                              provider.timesheetDetail?['time_logs']?.last;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.8,
                                ),
                                child: TimesheetRowupdateviewSheet(
                                  startdate: widget.startdate,
                                  timesheetId: widget.timesheetId!,
                                  timeLog: emptyLog ?? {}, // Pass the empty log
                                ),
                              );
                            },
                          );
                        },
                        child: const custom_text(
                            text: 'Add Row', color: primaryColor),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("End of the Day Review"),
                      const SizedBox(height: 10),
                      _buildTextField(endOfTheReviewController),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Tomorrows Plan"),
                      const SizedBox(height: 10),
                      _buildTextField(tomorrowplanController),
                    ],
                  ),
                ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            isTextFieldEdited = true; // Update the flag when the user types
          });
        },
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

  Widget _buildInfoBox(String text, {double fontSize = 14}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey)),
      child: custom_text(text: text, fontSize: fontSize),
    );
  }

  Widget _buildTimeLogTable(List<dynamic>? logs, BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          columnSpacing: 20, // Adjust spacing between columns
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => const Color.fromRGBO(238, 238, 238, 1),
          ),
          dataRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.white,
          ),
          columns: [
            _buildHeaderWithPadding('No.'),
            _buildHeaderWithPadding('Activity'),
            _buildHeaderWithPadding('From Time'),
            _buildHeaderWithPadding('Hours'),
            _buildHeaderWithPadding('Project'),
            const DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Icon(Icons.settings),
              ),
            ),
          ],
          rows: logs?.map((log) {
                return DataRow(
                  cells: [
                    _buildCell((log['idx']).toString()),
                    _buildCell(log['activity_type']?.toString() ?? "N/A"),
                    _buildCell(formatFromTime(log['from_time']) ?? ""),
                    _buildCell(roundHours(log['hours'] ?? 0).toString()),
                    _buildCell(log['project']?.toString() ?? "N/A"),
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

  DataColumn _buildHeaderWithPadding(String title) {
    return DataColumn(
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataCell _buildCell(String value) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Text(value),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(38, 50, 56, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const custom_text(
            text: 'Delete Timesheet',
            color: Colors.white,
          ),
          content: const custom_text(
            text: 'Are you sure you want to delete this timesheet?',
            color: Colors.white,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: const custom_text(
                text: 'Cancel',
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const custom_text(
                text: 'Delete',
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
