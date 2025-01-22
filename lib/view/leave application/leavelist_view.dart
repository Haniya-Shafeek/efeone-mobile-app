import 'package:efeone_mobile/controllers/leave.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/leave%20application/leaveEdit_view.dart';
import 'package:efeone_mobile/view/leave%20application/leave_application_view.dart';
import 'package:efeone_mobile/view/leave%20application/leave_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaveListview extends StatelessWidget {
  const LeaveListview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);

    Future<void> _refreshData() async {
      await controller.fetchLeaveApplications(context);
      await controller.fetchLeaveDetails();
    }

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
              builder: (context) => const LeaveApplicationScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: tertiaryColor,
        ),
      ),
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder(
          future: Future.wait([
            controller.fetchLeaveApplications(context),
            controller.fetchLeaveDetails(),
            controller.loadSharedPrefs()
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 8,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Container(
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      subtitle: Container(
                        height: 12,
                        color: Colors.grey[300],
                      ),
                      trailing: Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    const custom_text(
                      text: 'Failed',
                      fontSize: 18,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchLeaveApplications(context);
                      },
                      child:
                          const custom_text(text: 'Retry', color: primaryColor),
                    ),
                  ],
                ),
              );
            } else {
              List<Map<String, String>> leaveDetails = [
                {
                  'leaveType': 'Casual Leaves',
                  'title': 'Total Leave allocated',
                  'value': controller.totalLeaves.toString()
                },
                {
                  'leaveType': 'Casual Leaves',
                  'title': 'Leave Taken',
                  'value': controller.leavesTaken.toString()
                },
                {
                  'leaveType': 'Casual Leaves',
                  'title': 'Leaves Pending Approval',
                  'value': controller.leavesPendingApproval.toString()
                },
                {
                  'leaveType': 'Casual Leaves',
                  'title': 'Remaining Leaves',
                  'value': controller.remainingLeaves.toString()
                },
                {
                  'leaveType': 'Privilege Leave',
                  'title': 'Total Leave allocated',
                  'value': controller.privilegeLeaveTotal.toString()
                },
                {
                  'leaveType': 'Privilege Leave',
                  'title': 'Leave Taken',
                  'value': controller.privilegeLeaveTaken.toString()
                },
                {
                  'leaveType': 'Privilege Leave',
                  'title': 'Leaves Pending Approval',
                  'value': controller.privilegeLeavePendingApproval.toString()
                },
                {
                  'leaveType': 'Privilege Leave',
                  'title': 'Remaining Leaves',
                  'value': controller.privilegeLeaveRemaining.toString()
                },
              ];

              final groupedLeaveDetails = <String, List<Map<String, String>>>{};
              for (var detail in leaveDetails) {
                final type = detail['leaveType']!;
                if (groupedLeaveDetails.containsKey(type)) {
                  groupedLeaveDetails[type]!.add(detail);
                } else {
                  groupedLeaveDetails[type] = [detail];
                }
              }

              final leaveApplications = controller.leaveApplications;

              Color _getStatusColor(String? status) {
                switch (status) {
                  case 'Approved':
                    return Colors.green;
                  case 'Open':
                    return Colors.orange;
                  case 'Rejected':
                    return Colors.red;
                  default:
                    return Colors.black;
                }
              }

              return SingleChildScrollView(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom_text(
                      text: 'Leave Summary',
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    ...groupedLeaveDetails.entries.map((entry) {
                      final leaveType = entry.key;
                      final details = entry.value;

                      return ExpansionTile(
                        collapsedIconColor: Colors.blue,
                        iconColor: Colors.blue,
                        title: Text(
                          leaveType,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        children: [
                          ...details.map((detail) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(detail['title']!),
                                  Text(detail['value']!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent)),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    custom_text(
                      text: 'Leave Applications',
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: leaveApplications.map((application) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaveView(
                                  employee: application["employee_name"] ?? "",
                                  reason:
                                      application["description"] ?? 'No Reason',
                                  fromDate:
                                      application["from_date"] ?? 'No Fromdate',
                                  toDate: application["to_date"] ?? 'No Todte',
                                  isHalfDay:
                                      application["half_day"] ?? "No Halfday",
                                  halfDayDate:
                                      application["half_day_date"] ?? "",
                                  leaveType: application["leave_type"] ?? "",
                                  status: application['status'],
                                  totalLeaveDays:
                                      application["total_leave_days"],
                                  id: application["name"] ?? "",
                                  approver: application["leave_approver"] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        custom_text(
                                          text: '${application['name']}',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        const SizedBox(height: 4),
                                        custom_text(
                                          text:
                                              '${application['employee_name']}',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: custom_text(
                                      text: '${application['from_date']}',
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                                application['status'])
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        application['status'] ?? 'N/A',
                                        style: TextStyle(
                                          color: _getStatusColor(
                                              application['status']),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  if (application['status'] == 'Open' &&
                                      application['owner'] == controller.usr)
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: Colors.blueGrey[900],
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LeaveEditView(
                                                reason: application[
                                                        'description'] ??
                                                    '',
                                                fromDate:
                                                    application['from_date'] ??
                                                        '',
                                                isHalfDay:
                                                    application['half_day'] ??
                                                        '',
                                                halfDayDate: application[
                                                        'half_day_date'] ??
                                                    '',
                                                leaveType:
                                                    application['leave_type'] ??
                                                        '',
                                                toDate:
                                                    application['to_date'] ??
                                                        '',
                                                totalLeaveDays: application[
                                                        'total_leave_days'] ??
                                                    '',
                                                id: application['name'] ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
