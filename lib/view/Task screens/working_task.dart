import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/task_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/richtext.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';

class WorkingTaskpage extends StatelessWidget {
  const WorkingTaskpage({super.key});

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomepageController>(context);
    final plainTextDescriptions =
        controller.workingTaskdes.map(_removeHtmlTags).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: controller.workingTaskNames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: screenWidth * 0.1,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  custom_text(
                    text: "No tasks available",
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: controller.workingTaskNames.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Taskviewpage(
                          taskName: controller.workingTaskNames[index],
                          taskSubject: controller.workingTaskSub[index],
                          taskDes: controller.workingTaskdes[index],
                          taskSts: controller.workingTaskSts[index],
                          owner: controller.workingTaskowner[index],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: _buildTaskCard(
                      index: index,
                      title: controller.workingTaskNames[index],
                      subject: controller.workingTaskSub[index],
                      description: plainTextDescriptions[index],
                      owner: controller.workingTaskowner[index],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTaskCard({
    required int index,
    required String title,
    required String subject,
    required String description,
    required String owner,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tertiaryColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, // Responsive width
                  height: 40, // Responsive height
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: custom_text(
                    text: (index + 1).toString(),

                    color: tertiaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Responsive text size
                  ),
                ),
                const SizedBox(width: 16), // Responsive spacing
                Expanded(
                  child: custom_text(
                    text: title,

                    fontSize: 19, // Responsive text size
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Responsive spacing
            RichTextHelper.buildRichText("Subject", subject),
            const SizedBox(height: 8), // Responsive spacing
            RichTextHelper.buildRichText("Owner", owner),
          ],
        ),
      ),
    );
  }
}
