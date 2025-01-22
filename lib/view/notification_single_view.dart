import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatelessWidget {
  final String name;
  final String subject;
  final String assaigned;
  final String type;
  final String date;

  const NotificationView({
    super.key,
    required this.type,
    required this.subject,
    required this.name,
    required this.date,
    required this.assaigned,
  });

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<Notificationcontroller>(context);
    // notificationController.fetchNotifications();

    final document = parse(subject);
    final plainText = parse(document.body!.text).documentElement!.text;
    final notDate = formatDate(date);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseFontSize =
        screenWidth * 0.04; // Adjust base font size based on screen width

    return WillPopScope(
      onWillPop: () async {
      await  notificationController.fetchNotifications();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: 90,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
          actions: [
              IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.blue,
                size: 28,
              )),
          const SizedBox(
            width: 10,
          )
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard("Name", name, screenWidth, baseFontSize),
              SizedBox(height: screenHeight * 0.02),
              _buildDetailCard("Subject", plainText, screenWidth, baseFontSize),
              SizedBox(height: screenHeight * 0.02),
              _buildDetailCard(
                  "Assigned To", assaigned, screenWidth, baseFontSize),
              SizedBox(height: screenHeight * 0.02),
              _buildDetailCard("Date", notDate, screenWidth, baseFontSize),
              SizedBox(height: screenHeight * 0.02),
              _buildDetailCard("Type", type, screenWidth, baseFontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String content, double screenWidth, double baseFontSize) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              screenWidth * 0.03), // Responsive border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: baseFontSize * 1.1, // Responsive font size
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenWidth * 0.02), // Responsive spacing
            Text(
              content,
              style: TextStyle(
                fontSize: baseFontSize, // Responsive font size
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
