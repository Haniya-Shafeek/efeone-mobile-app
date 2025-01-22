import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Employee%20Checkin/checkin_single_view.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';

class EmployeeCheckinList extends StatefulWidget {
  const EmployeeCheckinList({super.key});

  @override
  State<EmployeeCheckinList> createState() => _EmployeeCheckinListState();
}

class _EmployeeCheckinListState extends State<EmployeeCheckinList> {
  final TextEditingController _searchController = TextEditingController();
  String _filterText = '';
  String _selectedStatus = "All";

  final List<String> _statuses = ["All", "Check-In", "Check-Out"];
  late Future<void> _fetchCheckinFuture;

  @override
  void initState() {
    super.initState();
    // Cache the initial fetch future
    final controller =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    _fetchCheckinFuture = controller.fetchCheckin();

    _searchController.addListener(() {
      setState(() {
        _filterText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status ?? "All";
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    final controller2 = Provider.of<HomepageController>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        controller2.initialize();
        return true;
      },
      child: GestureDetector(
         onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: const CustomAppBar(),
          body: RefreshIndicator(
            onRefresh: () {
              // Refresh the cached future and data
              setState(() {
                _fetchCheckinFuture = controller.fetchCheckin();
              });
              return _fetchCheckinFuture;
            },
            child: FutureBuilder(
              future: _fetchCheckinFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (controller.checkinData.isEmpty) {
                  return const Center(
                    child: Text('No check-ins available.'),
                  );
                } else {
                  // Filter the data based on the search input and status
                  final checkinList = controller.checkinData.where((checkin) {
                    final matchesSearch = checkin['employee_name']
                            ?.toLowerCase()
                            .contains(_filterText) ??
                        false;
                    final matchesStatus = _selectedStatus == "All" ||
                        (checkin['log_type'] == 'IN' &&
                            _selectedStatus == "Check-In") ||
                        (checkin['log_type'] == 'OUT' &&
                            _selectedStatus == "Check-Out");
      
                    return matchesSearch && matchesStatus;
                  }).toList();
      
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search by employee name...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status Dropdown
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  items: _statuses
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: _onStatusChanged,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                              top: screenHeight * 0.02,
                              bottom: screenHeight * 0.025),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Employee Check-in List',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final checkin = checkinList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckinDetailsScreen(
                                          checkinData: checkin),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                  margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.02,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Employee Name
                                        Expanded(
                                          flex: 2,
                                          child: custom_text(
                                            text:
                                                checkin['employee_name'] ?? 'N/A',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: screenWidth * 0.035,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.02,
                                              vertical: screenHeight * 0.005,
                                            ),
                                            decoration: BoxDecoration(
                                              color: checkin['log_type'] == 'IN'
                                                  ? const Color.fromARGB(
                                                          255, 23, 103, 25)
                                                      .withOpacity(0.2)
                                                  : Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(
                                                  screenWidth * 0.015),
                                            ),
                                            child: custom_text(
                                              text: checkin['log_type'] == 'IN'
                                                  ? 'Check-In'
                                                  : 'Check-Out',
                                              color: checkin['log_type'] == 'IN'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth * 0.035,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          flex: 2,
                                          child: custom_text(
                                            text: formatCheckinTime(
                                                checkin['time'] ?? 'N/A'),
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenWidth * 0.03,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: checkinList.length,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
