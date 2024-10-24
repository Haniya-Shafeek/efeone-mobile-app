import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_single_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetForm_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimesheetListviewScreen extends StatelessWidget {
  const TimesheetListviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);
    // provider.fetchTimesheetDetails();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimesheetFormscreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: tertiaryColor,
        ),
      ),
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/efeone Logo.png',
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: const custom_text(
              text: 'Timesheet Overview', // Your title here

              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: provider.fetchTimesheetDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: custom_text(
                        text: 'Failed to load timesheets. Please try again.'),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    itemCount: provider.timesheet.length,
                    itemBuilder: (context, index) {
                      final tsItem = provider.timesheet[index];
                      final date = formatDate(tsItem['posting_date']);
                      final status = tsItem['status'];

                      // Determine the color based on the status
                      Color statusColor;
                      switch (status) {
                        case 'Submitted':
                          statusColor = Colors.green;
                          break;
                        case 'Draft':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimesheetDetailScreen(
                                  tsname: tsItem['name'] ?? ''),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Timesheet Name
                                Expanded(
                                  flex: 2,
                                  child: custom_text(
                                    text: tsItem['name'] ?? 'N/A',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),

                                // Posting Date
                                Expanded(
                                  flex: 1,
                                  child: custom_text(
                                    text: date,
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),
                                // Status with background color
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status ?? 'N/A',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // Edit Button if Status is 'Draft'
                                if (status == 'Draft')
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TimesheetEditViewScreen(
                                            timesheetId: tsItem['name'],
                                            review: tsItem[
                                                    'end_of_the_day_review'] ??
                                                '',
                                            plan:
                                                tsItem['tomorrows_plan'] ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
