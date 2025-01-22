import 'package:efeone_mobile/controllers/task.dart';
import 'package:efeone_mobile/view/Task%20screens/modal_task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpenTaskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return TaskPage(
      title: 'Open Tasks',
      taskNames: controller.openTaskNames,
      taskStatuses: controller.openTaskSts,
      taskSubjects: controller.openTaskSub,
      taskDescriptions: controller.openTaskdes,
      taskProjects: controller.openTaskproject,
      taskOwners: controller.openTaskowner,
      taskPriorities: controller.openTaskpriority,
      taskTypes: controller.openTasktype,
      taskParentTasks: controller.openTaskpartask,
      taskEndDates: controller.openTaskendDate,
    );
  }
}
class OverdueTaskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return TaskPage(
      title: 'Overdue Tasks',
      taskNames: controller.overdueTaskNames,
      taskStatuses: controller.overdueTaskSts,
      taskSubjects: controller.overdueTaskSub,
      taskDescriptions: controller.overdueTaskdes,
      taskProjects: controller.overdueproject,
      taskOwners: controller.overdueTaskowner,
      taskPriorities: controller.overduepriority,
      taskTypes: controller.overduetype,
      taskParentTasks: controller.overduepartask,
      taskEndDates: controller.overdueEndDate,
    );
  }
}

class PendingTaskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return TaskPage(
      title: 'Pending Task',
      taskNames: controller.pendingReviewTaskNames,
      taskStatuses: controller.pendingReviewTaskSts,
      taskSubjects: controller.pendingReviewTaskSub,
      taskDescriptions: controller.pendingReviewTaskdes,
      taskProjects: controller.pendingproject,
      taskOwners: controller.pendingReviewTaskowner,
      taskPriorities: controller.pendingpriority,
      taskTypes: controller.pendingtype,
      taskParentTasks: controller.pendingpartask,
      taskEndDates: controller.pendindTaskendDate,
    );
  }
}
class WorkingTaskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return TaskPage(
      title: 'Working Task',
      taskNames: controller.workingTaskNames,
      taskStatuses: controller.workingTaskSts,
      taskSubjects: controller.workingTaskSub,
      taskDescriptions: controller.workingTaskdes,
      taskProjects: controller.workingtaskproject,
      taskOwners: controller.workingTaskowner,
      taskPriorities: controller.workingtaskpriority,
      taskTypes: controller.workingtasktype,
      taskParentTasks: controller.workingtaskpartask,
      taskEndDates: controller.workingTaskebndDate,
    );
  }
}
class CompleteTaskpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return TaskPage(
      title: 'Completed Task',
      taskNames: controller.completeTaskNames,
      taskStatuses: controller.completeTaskSts,
      taskSubjects: controller.completeTaskSub,
      taskDescriptions: controller.completeTaskdes,
      taskProjects: controller.completeTaskproject,
      taskOwners: controller.completeTaskowner,
      taskPriorities: controller.completeTaskpriority,
      taskTypes: controller.completeTasktype,
      taskParentTasks: controller.completeTaskpartask,
      taskEndDates: controller.completeTaskendDate,
    );
  }
}
