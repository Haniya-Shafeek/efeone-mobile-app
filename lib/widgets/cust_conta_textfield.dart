import 'package:flutter/material.dart';
import 'package:efeone_mobile/widgets/cust_textfield.dart';

class TextFieldContainer extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final double padding;

  const TextFieldContainer({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.padding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: cust_textfield(
            
            controller: controller,
            text: hintText,
          ),
        ),
      ],
    );
  }
}
