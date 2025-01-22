import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/view/notification_single_view.dart';
import 'package:efeone_mobile/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseFontSize = screenWidth * 0.04;

    return ChangeNotifierProvider(
      create: (context) => Notificationcontroller()..fetchNotifications(),
      child: WillPopScope(
        onWillPop: () async{
           final controller = context.read<Notificationcontroller>();
          controller.fetchNotifications(); // Refresh notifications
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
          body: Consumer<Notificationcontroller>(
            builder: (context, controller, child) {
              if (controller.notname.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  padding:
                      EdgeInsets.all(screenWidth * 0.03), // Responsive padding
                  itemCount: controller.notname.length,
                  itemBuilder: (context, index) {
                    final document = parse(controller.notsub[index]);
                    final plainText =
                        parse(document.body!.text).documentElement!.text;
                    final String isRead = controller.notread[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              screenHeight * 0.01), // Responsive vertical padding
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.04), // Responsive border radius
                        ),
                        color:
                            isRead == '0' ? Colors.grey.shade200 : Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(
                              screenWidth * 0.04), // Responsive padding
                          onTap: () {
                            controller
                                .notificationRead(controller.notname[index]);
                            controller.fetchNotifications();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationView(
                                  type: controller.nottype[index],
                                  subject: controller.notsub[index],
                                  name: controller.taskname[index],
                                  date: controller.notdate[index],
                                  assaigned: controller.notassaign[index],
                                ),
                              ),
                            );
                          },
                          title: Text(
                            controller.taskname[index],
                            style: TextStyle(
                              fontSize:
                                  baseFontSize * 1.1, // Responsive font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(
                                top: screenHeight *
                                    0.01), // Responsive top padding
                            child: Text(
                              plainText,
                              style: TextStyle(
                                fontSize: baseFontSize, // Responsive font size
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          trailing: isRead == '0'
                              ? Container(
                                  width: screenWidth * 0.025, // Responsive width
                                  height:
                                      screenWidth * 0.025, // Responsive height
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
