import 'package:efeone_mobile/view/Task%20screens/open_task.dart';
import 'package:efeone_mobile/view/Task%20screens/overdue_task.dart';
import 'package:efeone_mobile/view/Task%20screens/pending_task.dart';
import 'package:efeone_mobile/view/Task%20screens/template_task.dart';
import 'package:efeone_mobile/view/Task%20screens/working_task.dart';
import 'package:efeone_mobile/widgets/cust_tabbar.dart';
import 'package:flutter/material.dart';

class Tasktabbar extends StatelessWidget {
  const Tasktabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 90,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
      body: CustomTabBar(
          tabs: const [
            'Open',
            'Working',
            'Pending Review',
            'Overdue',
            'Template'
          ],
          screens: const [
            OpenTaskpage(),
            WorkingTaskpage(),
            PendingReviewTaskpage(),
            OverdueTaskpage(),
            TemplateTaskpage()
          ],
          onTabChanged: (index) {
            print('Tab changed to: $index');
          }),
    );
  }
}
