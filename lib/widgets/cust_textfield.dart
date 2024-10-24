import 'package:flutter/material.dart';

class cust_textfield extends StatelessWidget {
  const cust_textfield(
      {super.key,
      required this.controller,
      required this.text,
      this.lines,
      this.validator,
      this.onChanged});
  final TextEditingController controller;
  final String text;
  final int? lines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: lines,
      onChanged: onChanged,
      
      controller: controller,
      decoration: InputDecoration(
        hintText: text,
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        border: InputBorder.none,
      ),
      validator: validator,
    );
  }
}
