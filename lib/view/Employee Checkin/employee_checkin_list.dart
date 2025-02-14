import 'package:efeone_mobile/widgets/cust_filter_dropown.dart';
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
  String _selectedFilter = "My Check-In";
  final List<String> _filters = ["My Check-In", "Team Check-In"];

  @override
  void initState() {
    super.initState();
    final controller =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    controller.loadSharedPrefs();
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

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
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
              setState(() {
                _fetchCheckinFuture = controller.fetchCheckin();
              });
              return _fetchCheckinFuture;
            },
            child: FutureBuilder(
              future: _fetchCheckinFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    padding: EdgeInsets.all(screenWidth * 0.04),
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
                } else if (controller.checkinData.isEmpty) {
                  return const Center(
                    child: Text('No check-ins available.'),
                  );
                } else {
                  final myEmail =
                      controller.logmail?.trim().toLowerCase() ?? "";
                  print(
                      "Current User Email: '$myEmail'"); // Ensure no hidden spaces

                  final checkinList = controller.checkinData.where((checkin) {
                    final checkinOwner =
                        checkin['owner']?.trim().toLowerCase() ?? "";

                    final matchesSearch = checkin['employee_name']
                            ?.toLowerCase()
                            .contains(_filterText) ??
                        false;
                    final matchesStatus = _selectedStatus == "All" ||
                        (checkin['log_type'] == 'IN' &&
                            _selectedStatus == "Check-In") ||
                        (checkin['log_type'] == 'OUT' &&
                            _selectedStatus == "Check-Out");

                    final isMyCheckin = _selectedFilter == "My Check-In" &&
                        checkinOwner == myEmail;
                    final isTeamCheckin = _selectedFilter == "Team Check-In" &&
                        checkinOwner != myEmail;

                    return matchesSearch &&
                        matchesStatus &&
                        (isMyCheckin || isTeamCheckin);
                  }).toList();

                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: CustomScrollView(
                      slivers: [
                        // Title at the top of the UI
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: screenHeight * 0.01,
                              bottom: screenHeight * 0.01,
                            ),
                            child: const Text(
                              'Employee Check-in List',
                              style: TextStyle(
                                fontSize: 18, // Adjust font size for prominence
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 2, 51, 91),
                              ),
                            ),
                          ),
                        ),

                        // Search bar and dropdown
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.01),
                                      hintText: 'Search by employee',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  flex: 2,
                                  child: CustomDropdown(
                                    value: _selectedStatus,
                                    items: _statuses,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedStatus = newValue!;
                                      });
                                    },
                                  ))
                            ],
                          ),
                        ),

                        // Filter buttons
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 6, top: screenHeight * 0.02, bottom: 20),
                            child: Row(
                              children: _filters.map((filter) {
                                final isSelected = filter == _selectedFilter;
                                return GestureDetector(
                                  onTap: () => _onFilterChanged(filter),
                                  child: Container(
                                    width: screenWidth * 0.4,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.05,
                                        vertical: screenHeight * 0.01),
                                    margin: EdgeInsets.only(
                                        right: screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color.fromARGB(255, 2, 51, 91)
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: custom_text(
                                        text: filter,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 2, 51, 91),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Check-in List
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final checkin = checkinList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CheckinDetailsScreen(
                                              checkinData: checkin),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                  margin: EdgeInsets.only(
                                      bottom: screenHeight * 0.02),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: custom_text(
                                            text: checkin['employee_name'] ??
                                                'N/A',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: custom_text(
                                              text: checkin['log_type'] == 'IN'
                                                  ? 'Check-In'
                                                  : 'Check-Out',
                                              color: checkin['log_type'] == 'IN'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 14,
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
                                            color: Colors.grey,
                                            fontSize: 14,
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
