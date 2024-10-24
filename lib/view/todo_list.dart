import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/view/todo_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoListview extends StatelessWidget {
  const TodoListview({super.key});

  @override
  Widget build(BuildContext context) {
    final homepageController =
        Provider.of<HomepageController>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: screenWidth * 0.2,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
        ),
        centerTitle: true,
      ),
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
                future: homepageController
                    .fetchTodo(), // Calling the fetchTodo method
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the future is still running, show a loading indicator
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If there was an error, display an error message
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (homepageController.todotype.isEmpty) {
                    // If no todos were fetched, show a placeholder message
                    return const Center(
                      child: Text('No todos available.'),
                    );
                  } else {
                    // When data is fetched successfully, display the list
                    return ListView.builder(
                      itemCount: homepageController.todotype.length,
                      itemBuilder: (context, index) {
                        if (homepageController.todosts[index].toLowerCase() ==
                            'cancelled') {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Todoview(
                                  name: homepageController.todoname[index],
                                  description:
                                      homepageController.tododes[index],
                                  status: homepageController.todosts[index],
                                  type: homepageController.todotype[index],
                                  assigned: homepageController.todoassgn[index],
                                  modified:
                                      homepageController.todomodify[index],
                                  date: homepageController.tododate[index],
                                ),
                              ),
                            );
                          },
                          child: Card(
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
                                      text: homepageController.todotype[index],
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),

                                  // Description
                                  Expanded(
                                    flex: 2,
                                    child: custom_text(
                                      text: homepageController.todoname[index],
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Status
                                  Expanded(
                                    flex: 2,
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
                                        text: homepageController.todosts[index],
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
