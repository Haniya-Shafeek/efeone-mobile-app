import 'package:efeone_mobile/utilities/helpers.dart';
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
  final List<String> taskcreation;

  const TaskPage(
      {super.key,
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
      required this.taskcreation});

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
                          creation: taskcreation[index]),
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
    required String creation,
    required BuildContext context,
  }) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  custom_text(
                    text: title,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  custom_text(
                    text: "Sub: $subject",
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  custom_text(
                    text: "Date: ${formatDatefromTime(creation)}",
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 90,
              child: custom_text(
                text: project,
                fontWeight: FontWeight.normal,
                color: primaryColor,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            // Adjusted height for better visibility
            SizedBox(
              height: 24, // Slightly reduced height
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6), // Balanced radius
                ),
                child: Center(
                  child: custom_text(
                    text: status,
                    fontSize: 10, // Adjusted font size
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
