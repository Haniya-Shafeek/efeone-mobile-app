import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final int? maxline;

  const CustomField({
    Key? key,
    required this.controller,
    this.onTap,
    this.maxline
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        maxLines: maxline,
        controller: controller,
        onTap: onTap,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
