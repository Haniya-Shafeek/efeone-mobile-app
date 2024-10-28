import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/view/profile_view.dart';
import 'package:geolocator/geolocator.dart';

class UserInfoSection extends StatefulWidget {
  const UserInfoSection({super.key});

  @override
  _UserInfoSectionState createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  late Timer _timer;
  late String _currentTime;
  bool isLoading = false;

  // Method to get time-based greeting
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
  Future<bool> _requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permission denied by the user
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are permanently denied
    await Geolocator.openAppSettings();
    return false;
  }

  // Permission granted
  return true;
}


  @override
  void initState() {
    super.initState();
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
    return Consumer<HomepageController>(
      builder: (context, homepageController, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ));
          },
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
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
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          custom_text(
                            text: _getGreetingMessage(),
                            color: Colors.black,
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 20,
                          ),
                          custom_text(
                            text: homepageController.username,
                            color: Colors.black,
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      CircleAvatar(
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
                  const SizedBox(height: 10),
                 Center(
  child: GestureDetector(
    onTap: () async {
      // Check for internet connection
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: custom_text(
                text: 'You\'re offline',
                color: Colors.white,
                fontSize: MediaQuery.of(context).textScaleFactor * 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2),
          ),
        );
        return; // Exit if no connection
      }

      // Request location permissions
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: custom_text(
              text: 'Location permission denied. Enable it in settings.',
              color: Colors.white,
              fontSize: MediaQuery.of(context).textScaleFactor * 16,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return; // Exit if no permission
      }

      // Retrieve current location
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print("Error retrieving location: $e");
        return;
      }

      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(
              homepageController.isCheckedIn
                  ? 'Confirm Check-Out'
                  : 'Confirm Check-In',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Text(
              homepageController.isCheckedIn
                  ? 'Do you really want to check-out?'
                  : 'Do you really want to check-in?',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
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
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  homepageController.isCheckedIn
                      ? 'Check-Out'
                      : 'Check-In',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // If user confirms, proceed with check-in/check-out
      if (confirm) {
        setState(() {
          isLoading = true;
        });

        // Current time
        final currentTime = DateTime.now().toIso8601String();

        await homepageController.toggleCheckInStatus(
            position.latitude, position.longitude);

        setState(() {
          isLoading = false;
        });

        final statusMessage = homepageController.isCheckedIn
            ? 'You are successfully checked in'
            : 'You are successfully checked out';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: homepageController.isCheckedIn
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: custom_text(
                text: statusMessage,
                color: Colors.white,
                fontSize: MediaQuery.of(context).textScaleFactor * 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: homepageController.isCheckedIn ? Colors.red : Colors.green,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            homepageController.isCheckedIn
                ? Icons.arrow_circle_left
                : Icons.arrow_circle_right,
            color: homepageController.isCheckedIn ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 3),
          Text(
            homepageController.isCheckedIn ? 'Check-Out' : 'Check-In',
            style: TextStyle(
              color: homepageController.isCheckedIn ? Colors.red : Colors.green,
              fontSize: MediaQuery.of(context).textScaleFactor * 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
