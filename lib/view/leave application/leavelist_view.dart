import 'package:efeone_mobile/controllers/leave.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/leave%20application/leaveEdit_view.dart';
import 'package:efeone_mobile/view/leave%20application/leave_application_view.dart';
import 'package:efeone_mobile/view/leave%20application/leave_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:efeone_mobile/widgets/leave_balance_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaveListview extends StatefulWidget {
  const LeaveListview({super.key});

  @override
  State<LeaveListview> createState() => _LeaveListviewState();
}

class _LeaveListviewState extends State<LeaveListview> {
  String _selectedFilter = "My Leave"; // Default filter
  final List<String> _filters = ["My Leave", "Team Leave"];

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

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
              final currentUser = controller.usr?.trim().toLowerCase() ?? '';
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
                    return const Color.fromARGB(255, 103, 94, 94);
                }
              }

              return SingleChildScrollView(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom_text(
                      text: 'Leave Balance',
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: const Color.fromARGB(255, 2, 51, 91),
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HalfDoughnutChart(
                          totalLeaves: (controller.totalLeaves ?? 0).toDouble(),
                          leavesRemaining:
                              controller.remainingLeaves.toDouble(),
                          baseColor:
                              Colors.pinkAccent, // Rose color for Casual Leave
                          title: 'Casual Leave Balance',
                        ),
                        const SizedBox(width: 20),
                        HalfDoughnutChart(
                          totalLeaves:
                              (controller.privilegeLeaveTotal ?? 0).toDouble(),
                          leavesRemaining:
                              controller.privilegeLeaveRemaining.toDouble(),
                          baseColor:
                              Colors.purple, // Purple color for Privilege Leave
                          title: 'Privilege Leave Balance',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    custom_text(
                      text: 'Leave Applications',
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      color: const Color.fromARGB(255, 2, 51, 91),
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),

                    // Filter Selection Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 8.0),
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = filter == _selectedFilter;
                          return GestureDetector(
                            onTap: () => _onFilterChanged(filter),
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color.fromARGB(255, 2, 51, 91)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: custom_text(
                                  text: filter,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color.fromARGB(255, 2, 51, 91),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: leaveApplications.where((application) {
                        final owner =
                            application['owner']?.trim().toLowerCase() ?? '';

                        if (_selectedFilter == "My Leave") {
                          return owner == currentUser;
                        } else if (_selectedFilter == "Team Leave") {
                          return owner != currentUser && owner.isNotEmpty;
                        }
                        return false;
                      }).map((application) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaveEditView(
                                  reason: application['description'] ?? '',
                                  owner: application['owner']??'',
                                  status: application['status'],
                                  approver: application['leave_approver'],
                                  fromDate: application['from_date'] ?? '',
                                  isHalfDay: application['half_day'] ?? '',
                                  halfDayDate:
                                      application['half_day_date'] ?? '',
                                  leaveType: application['leave_type'] ?? '',
                                  toDate: application['to_date'] ?? '',
                                  totalLeaveDays:
                                      application['total_leave_days'] ?? '',
                                  id: application['name'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
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
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow
                                              .ellipsis, // Add this to prevent overflow
                                        ),
                                        const SizedBox(height: 4),
                                        custom_text(
                                          text:
                                              '${application['employee_name']}',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.030,
                                          color: const Color.fromARGB(
                                              255, 87, 86, 86),
                                          overflow: TextOverflow
                                              .ellipsis, // Add this to prevent overflow
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: custom_text(
                                      text:
                                          formatDate(application['from_date']),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: Colors.grey,
                                      overflow: TextOverflow
                                          .ellipsis, // Add this to prevent overflow
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
                                        overflow: TextOverflow
                                            .ellipsis, // Add this to prevent overflow
                                      ),
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
