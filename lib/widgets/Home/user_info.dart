import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/view/profile_view.dart';

class UserInfoSection extends StatefulWidget {
  final Function(bool) toggleLoading;
  const UserInfoSection({super.key, required this.toggleLoading});

  @override
  _UserInfoSectionState createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  late Timer _timer;
  late String _currentTime;

  // Get greeting based on time
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  // Request location permissions
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    final homepageController =
        Provider.of<HomepageController>(context, listen: false);
    homepageController.initialize();
    _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homepageController = Provider.of<HomepageController>(context);

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and Profile Image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom_text(
                      text: _getGreetingMessage(),
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).textScaleFactor * 20,
                    ),
                    custom_text(
                      text: '${homepageController.username} 👋',
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).textScaleFactor * 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    widget.toggleLoading(true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    ).then((_) => widget.toggleLoading(false));
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.1,
                    backgroundImage: homepageController.imgurl.isNotEmpty
                        ? NetworkImage(homepageController.imgurl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: homepageController.imgurl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: MediaQuery.of(context).size.width * 0.1,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            custom_text(
              text: homepageController.isCheckedIn
                  ? 'Last check-in at ${homepageController.logtime}'
                  : 'Last check-out at ${homepageController.logtime}',
              fontSize: MediaQuery.of(context).textScaleFactor * 17,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 119, 118, 118),
            ),
            custom_text(
              text: _currentTime,
              fontSize: MediaQuery.of(context).textScaleFactor * 18,
              fontWeight: FontWeight.w400,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),
            // Check-in/Check-out Button
            Center(
              child: GestureDetector(
                onTap: () async {
                  widget.toggleLoading(true);

                  var connectivityResult =
                      await Connectivity().checkConnectivity();
                  if (connectivityResult == ConnectivityResult.none) {
                    widget.toggleLoading(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: custom_text(
                          text: 'You\'re offline',
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).textScaleFactor * 16,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  bool hasPermission = await _requestLocationPermission();
                  if (!hasPermission) {
                    widget.toggleLoading(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: custom_text(
                          text:
                              'Location permission denied. Enable it in settings.',
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).textScaleFactor * 16,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  Position position;
                  try {
                    position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high);
                  } catch (e) {
                    widget.toggleLoading(false);
                    return;
                  }

                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.blueGrey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        title: custom_text(
                          text: homepageController.isCheckedIn
                              ? 'Confirm Check-Out'
                              : 'Confirm Check-In',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        content: custom_text(
                          text: homepageController.isCheckedIn
                              ? 'Do you really want to check-out?'
                              : 'Do you really want to check-in?',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: custom_text(
                              text: homepageController.isCheckedIn
                                  ? 'Check-Out'
                                  : 'Check-In',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm) {
                    await homepageController.toggleCheckInStatus(
                        position.latitude, position.longitude, context);
                  }
                  widget.toggleLoading(false);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: homepageController.isCheckedIn
                          ? Colors.red
                          : Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        homepageController.isCheckedIn
                            ? Icons.arrow_circle_left_outlined
                            : Icons.arrow_circle_right_outlined,
                        color: homepageController.isCheckedIn
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        homepageController.isCheckedIn
                            ? 'Check-Out'
                            : 'Check-In',
                        style: TextStyle(
                            fontSize: 18,
                            color: homepageController.isCheckedIn
                                ? Colors.red
                                : Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
