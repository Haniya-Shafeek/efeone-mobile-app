import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/ECP/Ecp_application_view.dart';
import 'package:efeone_mobile/view/ECP/Ecp_edit_view.dart';
import 'package:efeone_mobile/view/ECP/Ecp_single_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckinPermissionListScreen extends StatelessWidget {
  const CheckinPermissionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckinPermissionScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: tertiaryColor,
        ),
      ),
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/efeone Logo.png',
            width: MediaQuery.of(context).size.width * 0.2,
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
              text: 'Ecp Overview', // Your title here
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: provider.fetchCheckinPermissionDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: custom_text(text: 'Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    itemCount: provider.ecp.length,
                    itemBuilder: (context, index) {
                      final ecpItem = provider.ecp[index];
                      final date = formatDate(ecpItem['date']);
                      final status = ecpItem['workflow_state'] ?? 'N/A';

                      // Determine the color based on the status
                      Color statusColor;
                      switch (status) {
                        case 'Approved':
                          statusColor = Colors.green;
                          break;
                        case 'Draft':
                          statusColor = Colors.red;
                          break;
                        case 'Rejected':
                          statusColor = Colors.orange;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckinPermissionDetailScreen(
                                      ecpItem: ecpItem),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      custom_text(
                                        text: ecpItem['name'] ?? 'N/A',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      const SizedBox(height: 4),
                                      custom_text(
                                        text: ecpItem['employee_name'] ?? 'N/A',
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                ),

                                // Posting Date
                                Expanded(
                                  flex: 1,
                                  child: custom_text(
                                    text: date,
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // Status with background color
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status ?? 'N/A',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // Edit Button if Status is 'Draft'
                                if (status == 'Pending')
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Ecpeditview(
                                            ecpid: ecpItem["name"],
                                            arrivalTime:
                                                ecpItem["arrival_time"],
                                            date: ecpItem['date'],
                                            leavingTime:
                                                ecpItem["leaving_time"],
                                            logtype: ecpItem["log_type"],
                                            reason: ecpItem["reason"],
                                          ),
                                        ),
                                      );
                                    },
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
        ],
      ),
    );
  }
}
