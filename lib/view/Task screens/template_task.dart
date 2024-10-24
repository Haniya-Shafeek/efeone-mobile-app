import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/view/task_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/richtext.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';

class TemplateTaskpage extends StatelessWidget {
  const TemplateTaskpage({super.key});

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomepageController>(context);
    final plainTextDescriptions =
        controller.templateTaskdes.map(_removeHtmlTags).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: controller.templateTaskNames.isEmpty
          ? _buildEmptyState(screenWidth, screenHeight)
          : _buildTaskList(context, plainTextDescriptions, controller, screenHeight),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
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
    );
  }

  Widget _buildTaskList(BuildContext context, List<String> plainTextDescriptions, HomepageController controller, double screenHeight) {
    return ListView.builder(
      itemCount: controller.templateTaskNames.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Taskviewpage(
                  taskName: controller.templateTaskNames[index],
                  taskSubject: controller.templateTaskSub[index],
                  taskDes: controller.templateTaskdes[index],
                  taskSts: controller.templateTaskSts[index],
                  owner: controller.templateTaskowner[index],
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: _buildTaskCard(
              index: index,
              title: controller.templateTaskNames[index],
              subject: controller.templateTaskSub[index],
              description: plainTextDescriptions[index],
              owner: controller.templateTaskowner[index],
            ),
          ),
        );
      },
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
        color: Colors.grey[200],
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: custom_text(
                  text:  title,
                  
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
