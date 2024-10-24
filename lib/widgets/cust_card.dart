import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final Widget? leading;
  final IconData? trailingIcon;

  CustomCard({
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 5.0,
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle,
        trailing: Icon(trailingIcon),
        onTap: () {
          // Handle card tap if necessary
        },
      ),
    );
  }
}
