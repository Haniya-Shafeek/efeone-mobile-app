import 'package:efeone_mobile/utilities/constants.dart';
import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final int? maxline;

  const CustomField(
      {super.key, required this.controller, this.onTap, this.maxline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        maxLines: maxline,
        controller: controller,
        style: const TextStyle(color: maincolor),
        onTap: onTap,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(top: 3, bottom: 3),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
