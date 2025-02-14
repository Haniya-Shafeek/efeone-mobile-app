import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efeone_mobile/controllers/task.dart';
import 'package:efeone_mobile/view/Group%20Chat/chat_screen.dart';
import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/view/Employee%20Checkin/employee_checkin_list.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:efeone_mobile/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/view/Task%20screens/task_tabbar.dart';
import 'package:efeone_mobile/view/todo_list.dart';
import 'package:efeone_mobile/widgets/Home/notification._icon.dart';
import 'package:efeone_mobile/widgets/Home/user_info.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isLoading = false;

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> _fetchData(BuildContext context) async {
    final notificationController =
        Provider.of<Notificationcontroller>(context, listen: false);
    await notificationController.fetchNotifications();
    final taskcontroler = Provider.of<TaskController>(context, listen: false);
    taskcontroler.fetchTask(context);
    final homepageController =
        Provider.of<HomepageController>(context, listen: false);

    await homepageController.fetchLastLoginType();
    await homepageController.initialize();
    await _fetchLoggedInUserId();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(context);
    });
  }

  final items = [
    {
      'image': "assets/images/empcheckinicon.png",
      'label': 'Checkin',
      'route': const EmployeeCheckinList(),
    },
    {
      'image': "assets/images/todoicon.png",
      'label': 'Todo',
      'route': const TodoListview(),
    },
    {
      'image': "assets/images/timesheeticon.png",
      'label': 'Timesheet',
      'route': const TimesheetListviewScreen(),
    },
    {
      'image': "assets/images/leaveicon2.png", // Corrected key name
      'label': 'Leave',
      'route': const LeaveListview(),
    },
    {
      'image': "assets/images/checkinicon.png",
      'label': 'ECP',
      'route': const CheckinPermissionListScreen(),
    },
  ];
  String? loggedInUserId;

  Future<void> _fetchLoggedInUserId() async {
    // Replace with your logic to get the logged-in user's ID
    final prefs = await SharedPreferences.getInstance();
    loggedInUserId = prefs.getString('fullName');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: appbarporstion(context),
      body: SingleChildScrollView(
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserInfoSection(toggleLoading: toggleLoading),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const custom_text(
                        text: "Your Tasks",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 2, 51, 91)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Tasktabbar(initialTabIndex: 0),
                            ));
                      },
                      child: const custom_text(
                        text: "View All",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: Provider.of<TaskController>(context, listen: false)
                    .fetchTask(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        shrinkWrap: true,
                        childAspectRatio: 5 / 2,
                        children: List.generate(
                          4,
                          (index) => _buildDashboardCard(
                            onTap: () {},
                            txtcolor: Colors.grey,
                            title: 'Loading...',
                            borderColor:
                                const Color.fromARGB(255, 236, 235, 235),
                            fillColor:
                                Colors.grey.shade200, // Light shade inside
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return Consumer<TaskController>(
                      builder: (context, controller, child) {
                        final totalTasks = controller.taskname.length;
                        final openTasks = controller.tasksts
                            .where((status) => status.toLowerCase() == 'open')
                            .length;
                        final overdueTasks = controller.tasksts
                            .where(
                                (status) => status.toLowerCase() == 'overdue')
                            .length;
                        final workingTasks = controller.tasksts
                            .where(
                                (status) => status.toLowerCase() == 'working')
                            .length;
                        final pendingReviewTask = controller.tasksts
                            .where((status) =>
                                status.toLowerCase() == 'pending review')
                            .length;
                        final completeTask = controller.tasksts
                            .where(
                                (status) => status.toLowerCase() == 'Completed')
                            .length;

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 5 / 2,
                            children: [
                              _buildDashboardCard(
                                title: 'Total Tasks',
                                txtcolor: Colors.blue.shade900,
                                borderColor: Colors.blue[800]!,
                                fillColor:
                                    Colors.blue[50]!, // Light shade inside
                                count: totalTasks,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 0),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Open ',
                                txtcolor: Colors.blue.shade800,
                                borderColor: Colors.lightBlue,
                                fillColor:
                                    Colors.lightBlue[50]!, // Light shade inside
                                count: openTasks,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 0),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Working ',
                                txtcolor: Colors.green.shade800,
                                borderColor: Colors.green,
                                fillColor:
                                    Colors.green[50]!, // Light shade inside
                                count: workingTasks,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 1),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Overdue ',
                                txtcolor: Colors.red.shade900,
                                borderColor: Colors.red,
                                fillColor:
                                    Colors.red[50]!, // Light shade inside
                                count: overdueTasks,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 3),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Pending Review ',
                                txtcolor: Colors.orange,
                                borderColor: Colors.orange,
                                fillColor:
                                    Colors.orange[50]!, // Light shade inside
                                count: pendingReviewTask,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 2),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Completed ',
                                txtcolor: Colors.green[800]!,
                                borderColor: Colors.green[800]!,
                                fillColor:
                                    Colors.green[50]!, // Light shade inside
                                count: completeTask,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Tasktabbar(initialTabIndex: 4),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    custom_text(
                      text: "Employee Services",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 2, 51, 91),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.18,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Padding(
                      padding: EdgeInsets.all(screenHeight * 0.02),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item['route'] as Widget,
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.3,
                          height: screenHeight * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: screenHeight * 0.08,
                                child: Image.asset(
                                  item["image"].toString(),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              custom_text(
                                text: item['label'] as String,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 2, 51, 91),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          if (isLoading) // Show loading overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  AppBar appbarporstion(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[100],
      title: LayoutBuilder(
        builder: (context, constraints) {
          final double logoHeight = constraints.maxWidth > 600 ? 45 : 30;
          final double paddingValue = constraints.maxWidth > 600 ? 16.0 : 5.0;

          return Container(
            padding: EdgeInsets.all(paddingValue),
            child: Image.asset(
              'assets/images/efeone Logo.png',
              height: logoHeight,
            ),
          );
        },
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
              color: Color.fromARGB(255, 3, 98, 176),
              size: 28,
            )),
        Stack(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 3, 98, 176),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(5),
              ),
              onPressed: () async {
                // Update last seen timestamp
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt(
                    'lastSeenTimestamp', DateTime.now().millisecondsSinceEpoch);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupChatScreen(),
                  ),
                ).then((_) {
                  // After returning, trigger a refresh of the unread message count
                  setState(() {});
                });
              },
              child: const Icon(Icons.chat, size: 20),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc('groupChat1')
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || loggedInUserId == null) {
                    return Container();
                  }

                  final messages = snapshot.data!.docs;

                  return StreamBuilder<int>(
                    stream: SharedPreferences.getInstance()
                        .asStream()
                        .map((prefs) => prefs.getInt('lastSeenTimestamp') ?? 0),
                    builder: (context, lastSeenSnapshot) {
                      if (!lastSeenSnapshot.hasData) {
                        return Container();
                      }

                      final lastSeenTimestamp = lastSeenSnapshot.data!;
                      final newMessagesCount = messages.where((message) {
                        final messageTimestamp =
                            (message['timestamp'] as Timestamp)
                                .toDate()
                                .millisecondsSinceEpoch;
                        final senderId = message['senderId'];
                        return messageTimestamp > lastSeenTimestamp &&
                            senderId != loggedInUserId;
                      }).length;

                      if (newMessagesCount == 0) {
                        return Container();
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$newMessagesCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const NotificationStack(),
        const SizedBox(width: 20),
      ],
    );
  }
}

Widget _buildDashboardCard({
  required String title,
  int? count,
  required Color txtcolor,
  required Color borderColor,
  required Color fillColor, // Light shade inside card
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, // Ensure it takes full width
      constraints: const BoxConstraints(minHeight: 70), // Prevents shrinking
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent unnecessary stretching
          children: [
            if (count != null)
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: txtcolor,
                ),
              ),
            const SizedBox(height: 4), // Ensure spacing
            Flexible(
              // Ensures text does not overflow
              child: custom_text(
                text: title,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: txtcolor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
