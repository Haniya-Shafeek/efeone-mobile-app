import 'package:efeone_mobile/controllers/notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/view/notification_list_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';

class NotificationStack extends StatelessWidget {
  const NotificationStack({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.notifications_outlined,
            color: Color.fromARGB(255, 3, 98, 176),
            size: 28,
          ),
        ),
        Consumer<Notificationcontroller>(
          builder: (context, notificationcontroller, child) {
            return Visibility(
              visible: notificationcontroller.unreadCount > 0,
              child: Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: custom_text(
                    text: notificationcontroller.unreadCount.toString(),
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
