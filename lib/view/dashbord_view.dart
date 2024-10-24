import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/controllers/leave_application.dart';
import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:flutter/material.dart';
import 'package:efeone_mobile/utilities/griditem.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  final List<GridItem> items = [
    GridItem('Leave Application', Icons.work_off),
    GridItem('Food', Icons.fastfood),
    GridItem('Time Sheet', Icons.work_history),
    GridItem('Employee Checkin Permission', Icons.how_to_reg),
  ];

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = (screenWidth / 160).floor();
    final double itemHeight = screenWidth * 0.4;
    final double itemWidth = screenWidth / crossAxisCount;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: SizedBox(
          width: 90,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenWidth * 0.03,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (items[index].title == 'Leave Application') {
                  controller.loadSharedPrefs();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveListview(),
                    ),
                  );
                } else if (items[index].title ==
                    'Employee Checkin Permission') {
                  provider.loadSharedPrefs();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckinPermissionListScreen(),
                    ),
                  );
                }else if (items[index].title ==
                    'Time Sheet') {
                  provider.loadSharedPrefs();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimesheetListviewScreen(),
                    ),
                  );
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: GridTile(
                    header: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        items[index].title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    footer: const SizedBox(height: 12),
                    child: Center(
                      child: Icon(
                        items[index].icon,
                        size: screenWidth * 0.12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
