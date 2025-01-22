import 'dart:async';
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
  String _selectedStatus = "All";

  final List<String> _statuses = ["All", "Approved", "Pending", "Rejected"];
  late Future<void> _checkinPermissionsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar and Status Dropdown
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search by employee name...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const custom_text(
                text: 'ECP Overview',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: FutureBuilder(
                  future: _checkinPermissionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: custom_text(text: 'Error: ${snapshot.error}'),
                      );
                    } else {
                      // Filter items
                      final filteredItems = provider.ecp.where((ecpItem) {
                        final nameMatches = (ecpItem['employee_name'] ?? '')
                            .toLowerCase()
                            .contains(_searchQuery);
                        final statusMatches = _selectedStatus == "All" ||
                            ecpItem['workflow_state'] == _selectedStatus;
                        return nameMatches && statusMatches;
                      }).toList();

                      if (filteredItems.isEmpty) {
                        return const Center(
                          child: custom_text(
                            text: 'No items match your search.',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final ecpItem = filteredItems[index];
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
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02,
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
                                            text: ecpItem['employee_name'] ??
                                                'N/A',
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: custom_text(
                                        text: date,
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    if (status == 'Pending' &&
                                        ecpItem['owner'] == provider.logmail)
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Ecpeditview(
                                                employee: ecpItem["employee"],
                                                empname:
                                                    ecpItem["employee_name"],
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
            ),
          ],
        ),
      ),
    );
  }
}
