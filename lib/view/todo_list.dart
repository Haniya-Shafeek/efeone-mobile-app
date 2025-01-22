import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/controllers/task.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/search_view.dart';
import 'package:efeone_mobile/view/todo_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoListview extends StatelessWidget {
  const TodoListview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const custom_text(
                text: 'Todo Overview',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              )),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: FutureBuilder(
                future: controller.fetchTodo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 8,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Container(
                              height: 16,
                              color: Colors.grey[300],
                            ),
                            subtitle: Container(
                              height: 12,
                              color: Colors.grey[300],
                            ),
                            trailing: Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (controller.todotype.isEmpty) {
                    return const Center(
                      child: Text('No todos available.'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: controller.todotype.length,
                      itemBuilder: (context, index) {
                        if (controller.todosts[index].toLowerCase() ==
                            'cancelled') {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Todoview(
                                  name: controller.todoname[index],
                                  description: controller.tododes[index],
                                  status: controller.todosts[index],
                                  type: controller.todotype[index],
                                  assigned: controller.todoassgn[index],
                                  modified: controller.todomodify[index],
                                  date: controller.tododate[index],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Todo Name
                                  Expanded(
                                    flex: 2,
                                    child: custom_text(
                                      text: controller.tododes[index],
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Status
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: custom_text(
                                        text: controller.todosts[index],
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
