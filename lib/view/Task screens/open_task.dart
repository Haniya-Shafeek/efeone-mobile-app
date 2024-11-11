import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/Task%20screens/task_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpenTaskpage extends StatelessWidget {
  const OpenTaskpage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomepageController>(context);

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        child: controller.openTaskNames.isEmpty
            ? Center(
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
              )
            : ListView.builder(
                itemCount: controller.openTaskNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Taskviewpage(
                            taskName: controller.openTaskNames[index],
                            taskSubject: controller.openTaskSub[index],
                            taskDes: controller.openTaskdes[index],
                            taskSts: controller.openTaskSts[index],
                            owner: controller.openTaskowner[index],
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
                        title: controller.openTaskNames[index],
                        status: controller.openTaskSts[index],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTaskRow(
      {required String title,
      required String status,
      required BuildContext context}) {
    // Determine the color based on the status
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: custom_text(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: custom_text(
                text: status,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
