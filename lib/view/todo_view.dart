import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class Todoview extends StatelessWidget {
  final String name;
  final String description;
  final String status;
  final String type;
  final String assigned;
  final String modified;
  final String date;

  const Todoview({
    super.key,
    required this.name,
    required this.description,
    required this.status,
    required this.type,
    required this.assigned,
    required this.modified,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRichText("Type", type,
                    fontWeight: FontWeight.bold, color: Colors.black87),
                const SizedBox(height: 16),
                _buildRichText("Description", description),
                const SizedBox(height: 12),
                _buildRichText("Date", date),
                const SizedBox(height: 12),
                _buildRichText("Assigned by", assigned),
                const SizedBox(height: 12),
                _buildRichText("Modified by", modified),
                const SizedBox(height: 12),
                _buildRichText("Status", status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String label, String value,
      {FontWeight fontWeight = FontWeight.normal, Color color = Colors.grey}) {
    return Row(
      children: [
        Expanded(
          child: custom_text(
            text: "$label:",
            fontSize: 16,
            fontWeight: fontWeight,
            color: Colors.black54,
          ),
        ),
        Expanded(
          flex: 2,
          child: custom_text(
            text: value,
            fontSize: 16,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}
