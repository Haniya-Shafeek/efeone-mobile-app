import 'package:efeone_mobile/controllers/profile.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/utilities/helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, String>> _getProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('user_name') ?? 'No name';
    String imgurl = prefs.getString('img_url') ?? '';
    String id = prefs.getString('id') ?? 'No ID';
    String email = prefs.getString('email') ?? 'No email';
    String dob = prefs.getString('dob') ?? 'No date of birth';
    String designation = prefs.getString('designation') ?? 'No designation';
    String dateOfJoining =
        prefs.getString('dateofjoing') ?? 'No date of joining';

    return {
      'name': name,
      'img_url': imgurl,
      'id': id,
      'email': email,
      'dob': dob,
      'designation': designation,
      'dateOfJoining': dateOfJoining,
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final controller = Provider.of<Profilecontroller>(context, listen: false);
    controller.getempdetails();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final controller = Provider.of<Profilecontroller>(context);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: screenWidth * 0.2,
          child: Image.asset('assets/images/efeone Logo.png'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: FutureBuilder<Map<String, String>>(
              future: _getProfileDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: primaryColor,
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var profileDetails = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.13,
                        backgroundColor: Colors.blueGrey[900],
                        backgroundImage:
                            NetworkImage(profileDetails['img_url']!),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileInfoRow('Name: ', profileDetails['name']!),
                      _buildProfileInfoRow(
                          'Employee ID: ', profileDetails['id']!),
                      _buildProfileInfoRow('Email: ', profileDetails['email']!),
                      _buildProfileInfoRow(
                          'Date of Birth: ', formatDate(profileDetails['dob'])),
                      _buildProfileInfoRow(
                          'Designation: ', profileDetails['designation']!),
                      _buildProfileInfoRow('Date of Joining: ',
                          formatDate(profileDetails['dateOfJoining'])),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.blueGrey[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    title: const Text(
                                      'Confirm Logout',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: const Text(
                                      'Do you really want to logout?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.logout(context);
                                        },
                                        child: const Text(
                                          'LOG OUT',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: secondayColor,
                              size: 30,
                            ),
                            label: const Text(
                              "LOG OUT",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No profile data found.'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: secondayColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
