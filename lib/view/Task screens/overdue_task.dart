import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/task_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';

class OverdueTaskpage extends StatelessWidget {
  const OverdueTaskpage({super.key});

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomepageController>(context);

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        child: controller.overdueTaskNames.isEmpty
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
                itemCount: controller.overdueTaskNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Taskviewpage(
                            taskName: controller.overdueTaskNames[index],
                            taskSubject: controller.overdueTaskSub[index],
                            taskDes: controller.overdueTaskdes[index],
                            taskSts: controller.overdueTaskSts[index],
                            owner: controller.overdueTaskowner[index],
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
                        title: controller.overdueTaskNames[index],
                        status: controller.overdueTaskSts[index],
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