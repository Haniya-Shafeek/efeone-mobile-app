import 'dart:async';
import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_edit.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_single_view.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheetForm_view.dart';
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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TimesheetController>(context, listen: false);
    _fetchTimesheetDetails = provider.fetchTimesheetDetails();
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
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredTimesheets = provider.timesheet;
      });
    } else {
      setState(() {
        _filteredTimesheets = provider.timesheet
            .where((ts) =>
                (ts['name'] ?? '').toLowerCase().contains(_searchQuery) ||
                (ts['employee_name'] ?? '')
                    .toLowerCase()
                    .contains(_searchQuery) ||
                (ts['status'] ?? '').toLowerCase().contains(_searchQuery))
            .toList();
      });
    }
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.05,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search Timesheets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: const custom_text(
                text: 'Timesheet Overview',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: FutureBuilder(
                  future: _fetchTimesheetDetails,
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
                      return const Center(
                        child: custom_text(
                            text:
                                'Failed to load timesheets. Please try again.'),
                      );
                    } else {
                      final displayList = _searchQuery.isEmpty
                          ? provider.timesheet
                          : _filteredTimesheets;

                      if (displayList.isEmpty) {
                        return const Center(
                          child: custom_text(
                            text: 'No matching timesheets found.',
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final tsItem = displayList[index];
                          final date = formatDate(tsItem['start_date']);
                          final status = tsItem['status'];

                          // Determine the color based on the status
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
                                    // Timesheet Name
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          custom_text(
                                            text: tsItem['name'] ?? 'N/A',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          const SizedBox(height: 4),
                                          custom_text(
                                            text: tsItem['employee_name'] ??
                                                'N/A',
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                    if (status == 'Draft' &&
                                        tsItem['owner'] == provider.usr)
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TimesheetEditViewScreen(
                                                timesheetId:
                                                    tsItem['name'] ?? "",
                                                startdate:
                                                    tsItem["start_date"] ?? "",
                                                review: tsItem[
                                                        'end_of_the_day_review'] ??
                                                    '',
                                                plan:
                                                    tsItem['tomorrows_plan'] ??
                                                        '',
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
