import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.backgroundColor = primaryColor, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: custom_text(text: label,color: Colors.white,fontWeight: FontWeight.bold,),
    );
  }
}
