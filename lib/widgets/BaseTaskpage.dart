import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

abstract class BaseTaskPage extends StatelessWidget {
  final List<String> taskNames;
  final List<String> taskSub;
  final List<String> taskDes;
  final List<String> taskSts;
  final List<String> taskOwner;

  const BaseTaskPage({
    required this.taskNames,
    required this.taskSub,
    required this.taskDes,
    required this.taskSts,
    required this.taskOwner,
    super.key,
  });

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final plainTextDescriptions = taskDes.map(_removeHtmlTags).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: taskNames.isEmpty
          ? _buildEmptyState(screenWidth, screenHeight)
          : _buildTaskList(context, plainTextDescriptions, screenHeight),
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
          Text(
            "No tasks available",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<String> plainTextDescriptions, double screenHeight) {
    return ListView.builder(
      itemCount: taskNames.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _buildTaskView(index),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: _buildTaskCard(index, taskNames[index], taskSub[index], plainTextDescriptions[index], taskOwner[index]),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(int index, String title, String subject, String description, String owner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRichText("Subject", subject),
            const SizedBox(height: 8),
            _buildRichText("Owner", owner),
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildTaskView(int index); // To be implemented by subclasses
}
