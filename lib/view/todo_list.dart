import 'package:efeone_mobile/controllers/task.dart';
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
      appBar: const CustomAppBar(),
      body: FutureBuilder(
        future: controller.fetchTodo(), // Fetch once
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Consumer<TaskController>(
            builder: (context, controller, child) {
              // Filter out cancelled todos
              final filteredTodos = List.generate(
                      controller.todosts.length, (index) => index)
                  .where((index) =>
                      controller.todosts[index].toLowerCase() != 'Cancelled')
                  .toList();

              if (filteredTodos.isEmpty) {
                return const Center(child: Text('No todos available.'));
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: custom_text(
                          text: 'Todo Overview',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 2, 51, 91),
                        ),
                      ),
                      // ListView inside Column
                      ListView.builder(
                        shrinkWrap:
                            true, // Makes ListView adapt to content size
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        itemCount: controller.todotype.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Ensure all lists have enough items before accessing
                              if (index < controller.todoname.length &&
                                  index < controller.tododes.length &&
                                  index < controller.todosts.length &&
                                  index < controller.todotype.length &&
                                  index < controller.todoassgn.length &&
                                  index < controller.todomodify.length &&
                                  index < controller.tododate.length) {
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
                              }
                            },
                            child: Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Todo Name
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          custom_text(
                                            text: controller.tododes[index],
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ],
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
