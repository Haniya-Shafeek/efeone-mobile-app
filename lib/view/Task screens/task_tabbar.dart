import 'package:efeone_mobile/view/Task%20screens/task_list_view.dart';
import 'package:efeone_mobile/widgets/cust_tabbar.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class Tasktabbar extends StatelessWidget {
  final int? initialTabIndex;
  const Tasktabbar({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: CustomTabBar(
          initialIndex: initialTabIndex!,
          tabs: const [
            'Open',
            'Working',
            'Pending Review',
            'Overdue',
            'Completed'
          ],
          screens: [
            OpenTaskpage(),
            WorkingTaskpage(),
            PendingTaskpage(),
            OverdueTaskpage(),
            CompleteTaskpage()
          ],
          onTabChanged: (index) {
            print('Tab changed to: $index');
          }),
    );
  }
}
