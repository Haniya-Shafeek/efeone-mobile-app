import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/task_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/richtext.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';

class PendingReviewTaskpage extends StatelessWidget {
  const PendingReviewTaskpage({super.key});

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomepageController>(context);
    final plainTextDescriptions =
        controller.pendingReviewTaskdes.map(_removeHtmlTags).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: controller.pendingReviewTaskNames.isEmpty
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
                      text: "No tasks available for review",
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: controller.pendingReviewTaskNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Taskviewpage(
                            taskName: controller.pendingReviewTaskNames[index],
                            taskSubject: controller.pendingReviewTaskSub[index],
                            taskDes: controller.pendingReviewTaskdes[index],
                            taskSts: controller.pendingReviewTaskSts[index],
                            owner: controller.pendingReviewTaskowner[index],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: _buildTaskCard(
                        index: index,
                        title: controller.pendingReviewTaskNames[index],
                        subject: controller.pendingReviewTaskSub[index],
                        description: plainTextDescriptions[index],
                        owner: controller.pendingReviewTaskowner[index],
                      ),
                    ),
                  );
                },
              ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: custom_text(
                    text: (index + 1).toString(),
                    color: tertiaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: custom_text(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichTextHelper.buildRichText("Subject", subject),
            const SizedBox(height: 8),
            RichTextHelper.buildRichText("Owner", owner),
          ],
        ),
      ),
    );
  }
}
