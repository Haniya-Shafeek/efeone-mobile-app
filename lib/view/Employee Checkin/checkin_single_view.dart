import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckinDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> checkinData;

  const CheckinDetailsScreen({super.key, required this.checkinData});

  @override
  State<CheckinDetailsScreen> createState() => _CheckinDetailsScreenState();
}

class _CheckinDetailsScreenState extends State<CheckinDetailsScreen> {
  late GoogleMapController mapController;

  // Initial position for the map
  late CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
    provider.loadSharedPrefs();
    double latitude = widget.checkinData['latitude'] ?? 0.0;
    double longitude = widget.checkinData['longitude'] ?? 0.0;
    _initialPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 15.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinPermissionProvider>(context);
    double latitude = widget.checkinData['latitude'] ?? 0.0;
    double longitude = widget.checkinData['longitude'] ?? 0.0;
    final checkinid = widget.checkinData['name'];

    return WillPopScope(
      onWillPop: () async {
        provider.fetchCheckin();
        return true;
      },
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            // Background Map
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('checkin_location'),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: 'Check-in Location',
                    snippet: 'Lat: $latitude, Long: $longitude',
                  ),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            // Foreground Check-in Details (Reduced Size)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, // Reduce width
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Adjusted padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adjust height dynamically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("Employee Name",
                          widget.checkinData['employee_name'] ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildRow(
                          "Status",
                          widget.checkinData['log_type'] == 'IN'
                              ? 'Checked In'
                              : 'Checked Out',
                          textColor: widget.checkinData['log_type'] == 'IN'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold),
                      const SizedBox(height: 12),
                      _buildRow(
                        "Time",
                        formatCheckinTime(widget.checkinData['time']),
                      ),
                      const SizedBox(height: 12),
                      _buildRow(
                        "Longitude",
                        longitude.toString(),
                      ),
                      const SizedBox(height: 12),
                      _buildRow(
                        "Latitude",
                        latitude.toString(),
                      ),
                      const SizedBox(height: 16),
                      if (widget.checkinData['owner'] == provider.logmail)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: Colors.redAccent.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                                      'Confirm Deletion',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: const Text(
                                      'Do you really want to delete this item?',
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
                                        onPressed: () async {
                                          await provider.deleteCheckin(
                                              checkinid, context);
                                          Navigator.pop(context);
                                          provider.fetchCheckin();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Delete',
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
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
    );
  }

  // Helper Method: Builds a Key-Value Row
  Widget _buildRow(String title, String value,
      {Color textColor = Colors.black,
      FontWeight fontWeight = FontWeight.normal}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8), // Add spacing
        Expanded(
          // Prevent overflow
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis, // Trim long text
            maxLines: 1, // Show only one line
          ),
        ),
      ],
    );
  }

  // Helper Method: Formats Check-in Time
  String formatCheckinTime(String? time) {
    if (time == null) return 'N/A';
    try {
      DateTime parsedTime = DateTime.parse(time);
      // Format the time in 12-hour format with AM/PM
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }
}
