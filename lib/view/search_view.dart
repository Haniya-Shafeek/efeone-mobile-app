import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/view/Employee%20Checkin/employee_checkin_list.dart';
import 'package:efeone_mobile/view/Group%20Chat/chat_screen.dart';
import 'package:efeone_mobile/view/Task%20screens/task_tabbar.dart';
import 'package:efeone_mobile/view/Time%20Sheet/timesheet_list_view.dart';
import 'package:efeone_mobile/view/leave%20application/leavelist_view.dart';
import 'package:efeone_mobile/view/profile_view.dart';
import 'package:efeone_mobile/view/todo_list.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Leave Application',
      'icon': Icons.beach_access_sharp,
      'route': const LeaveListview()
    },
    {
      'name': 'Check-In',
      'icon': Icons.check_circle,
      'route': const EmployeeCheckinList()
    },
    {
      'name': 'Timesheet',
      'icon': Icons.access_time,
      'route': const TimesheetListviewScreen()
    },
    {
      'name': 'ECP',
      'icon': Icons.verified_user,
      'route': const CheckinPermissionListScreen()
    },
    {
      'name': 'Tasks',
      'icon': Icons.task,
      'route': Tasktabbar(
        initialTabIndex: 0,
      )
    },
    {'name': 'Todo', 'icon': Icons.list_alt, 'route': const TodoListview()},
    {'name': 'Profile', 'icon': Icons.person, 'route': const ProfilePage()},
    {'name': 'Chat', 'icon': Icons.chat, 'route': const GroupChatScreen()},
  ];

  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = _services; // Display all by default
  }

  void _searchServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _services;
      } else {
        _filteredServices = _services
            .where((service) =>
                service['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: _searchServices,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Search for services...',
                hintStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Services List
            Expanded(
              child: _filteredServices.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return Card(
                          color: Colors.white,
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey[50],
                              child: Icon(
                                service['icon'],
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            title: Text(
                              service['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => service['route'],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No services found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
