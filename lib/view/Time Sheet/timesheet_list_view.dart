import 'dart:async';
import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_single_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetForm_view.dart';
import 'package:efeone_mobile/widgets/cust_filter_dropown.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimesheetListviewScreen extends StatefulWidget {
  const TimesheetListviewScreen({super.key});

  @override
  _TimesheetListviewScreenState createState() =>
      _TimesheetListviewScreenState();
}

class _TimesheetListviewScreenState extends State<TimesheetListviewScreen> {
  late Future<void> _fetchTimesheetDetails;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _filteredTimesheets = [];
  String _searchQuery = "";
  String _selectedFilter = "My Timesheet"; // Default filter
  final List<String> _filters = ["My Timesheet", "Team Timesheet"];
  String _selectedStatus = "All"; // Default status filter
  final List<String> _statusFilters = ["All", "Draft", "Submitted"];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TimesheetController>(context, listen: false);
    provider.loadSharedPrefs();
    print("Current User: ${provider.usr}");
    _fetchTimesheetDetails = provider.fetchTimesheetDetails().then((_) {
      // After the Future is resolved, apply the filtering logic
      _filterTimesheets();
    });
    provider.loadSharedPrefs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
      _filterTimesheets();
    });
  }

  void _filterTimesheets() {
    final provider = Provider.of<TimesheetController>(context, listen: false);
    String currentUser = provider.usr!.trim().toLowerCase();

    setState(() {
      _filteredTimesheets = provider.timesheet.where((timesheetItem) {
        String owner = (timesheetItem['owner'] ?? "").trim().toLowerCase();
        String status = (timesheetItem['status'] ?? "").trim();

        final nameMatches =
            (timesheetItem['name'] ?? '').toLowerCase().contains(_searchQuery);
        final isMyTimesheet =
            _selectedFilter == "My Timesheet" && owner == currentUser;
        final isTeamTimesheet = _selectedFilter == "Team Timesheet" &&
            owner != currentUser &&
            owner.isNotEmpty;
        final statusMatches =
            _selectedStatus == "All" || status == _selectedStatus;

        return nameMatches &&
            (isMyTimesheet || isTeamTimesheet) &&
            statusMatches;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterTimesheets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimesheetController>(context);

    Future<void> _refreshData() async {
      await provider.fetchTimesheetDetails();
      _filterTimesheets();
    }

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
            provider.resetSaved();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimesheetFormscreen(),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: tertiaryColor,
          ),
        ),
        appBar: const CustomAppBar(),
        body: RefreshIndicator(
          color: Colors.blue,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const custom_text(
                    text: 'Timesheet Overview',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 2, 51, 91),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            hintText: 'Search Timesheets...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
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
                            items: _statusFilters,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedStatus = newValue!;
                                _filterTimesheets();
                              });
                            },
                          ))
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Filters Section
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = filter == _selectedFilter;
                        return GestureDetector(
                          onTap: () => _onFilterChanged(filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                  const SizedBox(height: 25),

                  // Timesheet List
                  FutureBuilder(
                    future: _fetchTimesheetDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          itemCount: 8,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
                        return const Center(
                          child: custom_text(
                            text:
                                'Failed to load timesheets. Please try again.',
                          ),
                        );
                      } else {
                        final displayList = _filteredTimesheets;

                        if (displayList.isEmpty) {
                          return const Center(
                            child: custom_text(
                              text: 'No timesheet found',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final tsItem = displayList[index];
                            final date = formatDate(tsItem['start_date']);
                            final status = tsItem['status'];

                            Color statusColor;
                            switch (status) {
                              case 'Submitted':
                                statusColor = Colors.green;
                                break;
                              case 'Draft':
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Colors.grey;
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TimesheetDetailScreen(
                                        tsname: tsItem['name'] ?? ''),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                              text: tsItem['name'] ?? 'N/A',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            custom_text(
                                              text: tsItem['employee_name'] ??
                                                  'N/A',
                                              color: const Color.fromARGB(
                                                  255, 87, 86, 86),
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 1,
                                        child: custom_text(
                                          text: date,
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: custom_text(
                                              text: status ?? 'N/A',
                                              color: statusColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Edit Button if Status is 'Draft'
                                      if (tsItem['status'] == 'Draft' &&
                                          tsItem['owner']
                                                  ?.trim()
                                                  .toLowerCase() ==
                                              provider.usr!
                                                  .trim()
                                                  .toLowerCase())
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TimesheetEditViewScreen(
                                                        timesheetId:
                                                            tsItem['name'] ??
                                                                "",
                                                        startdate: tsItem[
                                                                "start_date"] ??
                                                            "",
                                                        review: tsItem[
                                                                'end_of_the_day_review'] ??
                                                            '',
                                                        plan: tsItem[
                                                                'tomorrows_plan'] ??
                                                            '',
                                                      ),
                                                    ));
                                              }),
                                        )
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
