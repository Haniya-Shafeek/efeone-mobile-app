import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:efeone_mobile/view/task_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/view/Task%20screens/task_viewall.dart';
import 'package:efeone_mobile/view/todo_list.dart';
import 'package:efeone_mobile/widgets/Home/notification._icon.dart';
import 'package:efeone_mobile/widgets/Home/user_info.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Future<void> _fetchData(BuildContext context) async {
    final notificationController =
        Provider.of<Notificationcontroller>(context, listen: false);
    await notificationController.fetchNotifications();

    final homepageController =
        Provider.of<HomepageController>(context, listen: false);
    await homepageController.fetchLastLoginType();
    await homepageController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    _fetchData(context); // Initialize data fetching
    print(
      "assets/images/todoicon.png",
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
          NotificationStack(),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserInfoSection(),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const custom_text(
                    text: "Your Tasks",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 119, 118, 118),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Tasktabbar(),
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
              future: Provider.of<HomepageController>(context, listen: false)
                  .fetchTask(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: screenHeight * 0.25,
                      child: const Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Consumer<HomepageController>(
                    builder: (context, homepageController, child) {
                      return Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.25,
                            child: homepageController.taskname.isEmpty
                                ? const Center(
                                    child: custom_text(
                                        text: "No tasks available",
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        homepageController.taskname.length,
                                    itemBuilder: (context, index) {
                                      final status = homepageController
                                          .tasksts[index]
                                          .toLowerCase();
                                      final gradient =
                                          TaskStatusHelper.getGradient(status);

                                      if (status == 'completed' ||
                                          status == 'cancelled') {
                                        return const SizedBox.shrink();
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Taskviewpage(
                                                taskName: homepageController
                                                    .taskname[index],
                                                taskSubject: homepageController
                                                    .tasksub[index],
                                                taskDes: homepageController
                                                    .taskdes[index],
                                                taskSts: homepageController
                                                    .tasksts[index],
                                                owner: homepageController
                                                    .taskowner[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              screenHeight * 0.02),
                                          child: Container(
                                            width: screenWidth * 0.7,
                                            height: screenHeight * 0.18,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.7,
                                                  height: screenHeight * 0.12,
                                                  decoration: BoxDecoration(
                                                    gradient: gradient,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(30.0),
                                                      topLeft:
                                                          Radius.circular(30.0),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15,
                                                            top: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Icon(
                                                                Icons.schedule,
                                                                color: Colors
                                                                    .white),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                                minimumSize:
                                                                    const Size(
                                                                        50, 40),
                                                                backgroundColor:
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.5),
                                                              ),
                                                              onPressed: () {},
                                                              child:
                                                                  custom_text(
                                                                text: homepageController
                                                                        .tasksts[
                                                                    index],
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        custom_text(
                                                          text:
                                                              homepageController
                                                                      .taskname[
                                                                  index],
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        custom_text(
                                                          text: homepageController
                                                                          .startdate[
                                                                      index] ==
                                                                  "null"
                                                              ? ""
                                                              : "ESD : ${homepageController.startdate[index]}",
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        const TextSpan(
                                                          text: "Sub :",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    119,
                                                                    118,
                                                                    118),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              homepageController
                                                                      .tasksub[
                                                                  index],
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    119,
                                                                    118,
                                                                    118),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  custom_text(
                    text: "Employee Services",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 119, 118, 118),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.18,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final items = [
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
                      'image':
                          "assets/images/leaveicon2.png", // Corrected key name
                      'label': 'Leave',
                      'route': const LeaveListview(),
                    },
                    {
                      'image': "assets/images/checkinicon.png",
                      'label': 'ECP',
                      'route': const CheckinPermissionListScreen(),
                    },
                  ];

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
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
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
      ),
    );
  }
}

class TaskStatusHelper {
  static Gradient getGradient(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const LinearGradient(
          colors: [Colors.blue, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'working':
        return const LinearGradient(
          colors: [Colors.orange, Colors.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pending review':
        return const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'overdue':
        return const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey, Colors.grey[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
