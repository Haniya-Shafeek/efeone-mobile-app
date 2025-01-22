import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

class Taskviewpage extends StatelessWidget {
  final String taskName;
  final String taskSubject;
  final String taskDes;
  final String taskSts;
  final String owner;
  final String endDate;
  final String project;
  final String type;
  final String parentTask;
  final String priority;

  const Taskviewpage(
      {super.key,
      required this.taskName,
      required this.taskSubject,
      required this.taskDes,
      required this.taskSts,
      required this.owner,
      required this.project,
      required this.parentTask,
      required this.type,
      required this.priority,
      required this.endDate});

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final plainTextDescription = _removeHtmlTags(taskDes);

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTaskDetail('Subject', taskSubject),
              const SizedBox(height: 12),
              _buildTaskDetail('Assigned  By', owner, isOwner: true),
              const SizedBox(height: 12),
              _buildTaskDetail('Project', project),
              const SizedBox(height: 12),
              _buildTaskDetail('Task Type', type),

              const SizedBox(height: 12),
              _buildTaskDetail(
                  'Description',
                  plainTextDescription.isEmpty
                      ? "No description available"
                      : plainTextDescription),
              const SizedBox(height: 12),
              _buildTaskDetail('End Date', formatDate(endDate)),
              const SizedBox(height: 12),
              ...[
                const SizedBox(height: 12),
                _buildTaskDetail(
                    'Priority', priority ?? "No priority assigned"),
              ],
              // const SizedBox(height: 12),
              ...[
                const SizedBox(height: 12),
                _buildTaskDetail(
                    'Parent Task', parentTask ?? "No parent task assigned"),
              ],

              const SizedBox(height: 12),
              _buildTaskDetail('Status', taskSts, isStatus: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              taskName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetail(String title, String content,
      {bool isOwner = false, bool isStatus = false}) {
    return SizedBox(
      width: double.infinity, // Ensure the container takes up the full width
      child: Container(
        padding: const EdgeInsets.all(12.0), // Reduced padding for less height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (isOwner) ...[
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ] else if (isStatus) ...[
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
