import 'dart:async';
import 'package:efeone_mobile/widgets/cust_filter_dropown.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/ECP/Ecp_application_view.dart';
import 'package:efeone_mobile/view/ECP/Ecp_edit_view.dart';
import 'package:efeone_mobile/view/ECP/Ecp_single_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';

class CheckinPermissionListScreen extends StatefulWidget {
  const CheckinPermissionListScreen({super.key});

  @override
  State<CheckinPermissionListScreen> createState() =>
      _CheckinPermissionListScreenState();
}

class _CheckinPermissionListScreenState
    extends State<CheckinPermissionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";
  String _selectedStatus = "Pending";
  String _selectedFilter = "My ECP"; // Default filter

  final List<String> _statuses = ["All", "Approved", "Pending", "Rejected"];
  final List<String> _filters = ["My ECP", "Team ECP"];
  late Future<void> _checkinPermissionsFuture;

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    provider.loadSharedPrefs();
    _checkinPermissionsFuture = provider.fetchCheckinPermissionDetails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.trim().toLowerCase();
      });
    });
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

  Future<void> _refreshData() async {
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    await provider.fetchCheckinPermissionDetails();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
        appBar: const CustomAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ECP Overview Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.07,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: const custom_text(
                  text: 'ECP Overview',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 2, 51, 91),
                ),
              ),
              // Search Bar and Status Dropdown
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          hintText: "Search by employee name...",
                          hintStyle: TextStyle(color: Colors.grey[600]!),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[600]!),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide.none,
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

              const SizedBox(height: 5),

              // Filter Selection Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return GestureDetector(
                      onTap: () => _onFilterChanged(filter),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(right: 10),
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
                                : const Color.fromARGB(255, 2, 51, 91),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // List of ECP Items
              FutureBuilder(
                future: _checkinPermissionsFuture,
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
                  } else if (snapshot.hasError) {
                    return Center(
                      child: custom_text(text: 'Error: ${snapshot.error}'),
                    );
                  } else {
                    final filteredData = provider.ecp.where((ecpItem) {
                      final nameMatches = ecpItem['name']
                              ?.toLowerCase()
                              .contains(_searchController.text.toLowerCase()) ??
                          false;

                      final statusMatches = _selectedStatus == "All" ||
                          (ecpItem['workflow_state']?.toLowerCase() ?? "") ==
                              _selectedStatus.toLowerCase();

                      final isMyECP = _selectedFilter == "My ECP" &&
                          (ecpItem['owner']?.trim().toLowerCase() ==
                              provider.logmail?.trim().toLowerCase());

                      final isTeamECP = _selectedFilter == "Team ECP" &&
                          (ecpItem['owner']?.trim().toLowerCase() !=
                                  provider.logmail?.trim().toLowerCase() &&
                              ecpItem['owner'] != null &&
                              ecpItem['owner']!.isNotEmpty);

                      return nameMatches &&
                          statusMatches &&
                          (isMyECP || isTeamECP);
                    }).toList();

                    if (filteredData.isEmpty) {
                      return const Center(
                        child: custom_text(
                          text: 'No ECP found.',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final ecpItem = filteredData[index];
                        final date = formatDate(ecpItem['date']);
                        final status = ecpItem['workflow_state'] ?? 'N/A';
                        Color statusColor;
                        switch (status) {
                          case 'Approved':
                            statusColor = Colors.green;
                            break;
                          case 'Pending':
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
                                  builder: (context) => Ecpeditview(
                                    employee: ecpItem["employee"],
                                    owner: ecpItem['owner'],
                                    approver: ecpItem['reports_to_user'],
                                    empname: ecpItem["employee_name"],
                                    status: ecpItem['workflow_state'],
                                    ecpid: ecpItem["name"],
                                    arrivalTime: ecpItem["arrival_time"],
                                    date: ecpItem['date'],
                                    leavingTime: ecpItem["leaving_time"],
                                    logtype: ecpItem["log_type"],
                                    reason: ecpItem["reason"],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 5),
                                child: Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    margin: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    custom_text(
                                                      text: ecpItem['name'] ??
                                                          'N/A',
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    custom_text(
                                                      text: ecpItem[
                                                              'employee_name'] ??
                                                          'N/A',
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 87, 86, 86),
                                                      fontSize: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: custom_text(
                                                  text: date,
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontSize: 14,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ])))));
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
