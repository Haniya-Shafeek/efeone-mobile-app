import 'package:flutter/material.dart';
import 'package:efeone_mobile/view/Task%20screens/task_single_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/utilities/constants.dart';

class TaskPage extends StatelessWidget {
  final String title;
  final List<String> taskNames;
  final List<String> taskStatuses;
  final List<String> taskSubjects;
  final List<String> taskDescriptions;
  final List<String> taskProjects;
  final List<String> taskOwners;
  final List<String> taskPriorities;
  final List<String> taskTypes;
  final List<String> taskParentTasks;
  final List<String> taskEndDates;

  const TaskPage({
    super.key,
    required this.title,
    required this.taskNames,
    required this.taskStatuses,
    required this.taskSubjects,
    required this.taskDescriptions,
    required this.taskProjects,
    required this.taskOwners,
    required this.taskPriorities,
    required this.taskTypes,
    required this.taskParentTasks,
    required this.taskEndDates,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        child: taskNames.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                itemCount: taskNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // if (taskNames.isNotEmpty &&
                      //     taskProjects.isNotEmpty &&
                      //     taskParentTasks.isNotEmpty &&
                      //     taskPriorities.isNotEmpty &&
                      //     taskTypes.isNotEmpty &&
                      //     taskTypes.isNotEmpty &&
                      //     taskDescriptions.isNotEmpty &&
                      //     taskStatuses.isNotEmpty &&
                      //     taskEndDates.isNotEmpty &&
                      //     taskOwners.isNotEmpty) {
                      //   // Navigate to Taskviewpage
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Taskviewpage(
                      //         project: taskProjects[index],
                      //         parentTask: index < taskParentTasks.length
                      //             ? taskParentTasks[index]
                      //             : "null",
                      //         priority:index< taskPriorities.length?taskPriorities[index]:"null",
                      //         type: taskTypes[index],
                      //         taskName: taskNames[index],
                      //         taskSubject: taskSubjects[index],
                      //         taskDes: taskDescriptions[index],
                      //         taskSts: taskStatuses[index],
                      //         endDate: taskEndDates[index],
                      //         owner: taskOwners[index],
                      //       ),
                      //     ),
                      //   );
                      // } else {
                      //   if (taskNames.isEmpty) print("openTaskNames is empty!");
                      //   if (taskProjects.isEmpty) {
                      //     print("openTaskproject is empty!");
                      //   }
                      //   if (taskParentTasks.isEmpty) {
                      //     print("openTaskpartask is empty!");
                      //   }
                      //   if (taskPriorities.isEmpty) {
                      //     print("openTaskpriority is empty!");
                      //   }
                      //   if (taskTypes.isEmpty) print("openTasktype is empty!");
                      //   if (taskTypes.isEmpty) print("openTaskSub is empty!");
                      //   if (taskDescriptions.isEmpty) {
                      //     print("openTaskdes is empty!");
                      //   }
                      //   if (taskStatuses.isEmpty) {
                      //     print("openTaskSts is empty!");
                      //   }
                      //   if (taskEndDates.isEmpty) {
                      //     print("openTaskendDate is empty!");
                      //   }
                      //   if (taskOwners.isEmpty) {
                      //     print("openTaskowner is empty!");
                      //   }
                      // }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Taskviewpage(
                            project: taskProjects[index],
                            parentTask: index < taskParentTasks.length
                                ? taskParentTasks[index]
                                : "null",
                            priority: index < taskPriorities.length
                                ? taskPriorities[index]
                                : "null",
                            type: taskTypes[index],
                            taskName: taskNames[index],
                            taskSubject: taskSubjects[index],
                            taskDes: taskDescriptions[index],
                            taskSts: taskStatuses[index],
                            endDate: taskEndDates[index],
                            owner: taskOwners[index],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: _buildTaskRow(
                        context: context,
                        subject: taskSubjects[index],
                        project: taskProjects[index],
                        title: taskNames[index],
                        status: taskStatuses[index],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: MediaQuery.of(context).size.width * 0.1,
            color: Colors.blueGrey,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          custom_text(
            text: "No tasks available",
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow({
    required String title,
    required String subject,
    required String status,
    required String project,
    required BuildContext context,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Title and Subject
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  custom_text(
                    text: title,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 5), // Consistent spacing
                  custom_text(
                    text: "Sub : $subject",
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
            // Spacer between sections
            const Spacer(flex: 1),

            // Project
            Expanded(
              flex: 2,
              child: custom_text(
                text: project,
                fontWeight: FontWeight.normal,
                color: primaryColor,
                textAlign: TextAlign.center,
              ),
            ),
            // Spacer between sections
            const Spacer(flex: 1),

            // Status
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: custom_text(
                    text: status,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Define the method to get color based on the status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Working':
        return Colors.green;
      case 'Open':
        return Colors.blue;
      case 'Pending Review':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      case 'Completed':
        return Colors.green[800]!;
      default:
        return Colors.grey; // Default color for unknown statuses
    }
  }
}
