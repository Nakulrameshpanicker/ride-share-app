import 'dart:async'; // Import for debouncing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dpool.dart'; // Import the DPoolPage

class PassengerPage extends StatefulWidget {
  @override
  _PassengerPageState createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  GoogleMapController? _mapController;
  TextEditingController _startLocationController = TextEditingController();
  TextEditingController _destinationLocationController =
      TextEditingController();
  TextEditingController _passengerNameController = TextEditingController();

  LatLng? _startPoint;
  LatLng? _destinationPoint;
  Polyline? _routePolyline;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _startLocationController.addListener(() => _debounceUpdateLocation(true));
    _destinationLocationController
        .addListener(() => _debounceUpdateLocation(false));
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 400, // Increased height for the map
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.422, -122.084),
                  zoom: 12.0,
                ),
                onMapCreated: (controller) {
                  setState(() {
                    _mapController = controller;
                  });
                },
                markers: _startPoint != null && _destinationPoint != null
                    ? {
                        Marker(
                          markerId: const MarkerId('start'),
                          position: _startPoint!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                        ),
                        Marker(
                          markerId: const MarkerId('destination'),
                          position: _destinationPoint!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                        ),
                      }
                    : {},
                polylines: _routePolyline != null ? {_routePolyline!} : {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _startLocationController,
                decoration: InputDecoration(
                  labelText: 'Start Location',
                  hintText: 'Enter start location',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _destinationLocationController,
                decoration: InputDecoration(
                  labelText: 'Destination Location',
                  hintText: 'Enter destination location',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passengerNameController,
                decoration: InputDecoration(labelText: 'Passenger Name'),
              ),
            ),
            SizedBox(height: 20), // Added some space below the button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _requestPool,
                child: const Text('Request Pool'),
              ),
            ),
            SizedBox(height: 20), // Added some space below the button
          ],
        ),
      ),
    );
  }

  void _debounceUpdateLocation(bool isStartPoint) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _updateLocation(isStartPoint);
    });
  }

  void _updateLocation(bool isStartPoint) async {
    String locationName = isStartPoint
        ? _startLocationController.text
        : _destinationLocationController.text;
    if (locationName.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        LatLng selectedPoint =
            LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          if (isStartPoint) {
            _startPoint = selectedPoint;
          } else {
            _destinationPoint = selectedPoint;
          }
          _drawRoute();
        });

        // Move the map camera to the selected location with zoom
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
              selectedPoint, 15.0), // Adjust zoom level as needed
        );
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  void _drawRoute() {
    if (_startPoint == null || _destinationPoint == null) return;

    final List<LatLng> polylinePoints = [_startPoint!, _destinationPoint!];
    setState(() {
      _routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 5,
      );
    });
  }

  void _requestPool() {
    if (_startPoint == null || _destinationPoint == null) {
      // Show error message if start or destination points are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select start and destination points.'),
        ),
      );
      return;
    }

    final String passengerName = _passengerNameController.text;
    if (passengerName.isEmpty) {
      // Show error message if passenger name is not entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    // Access Firestore instance and reference the collection
    CollectionReference poolRequestsCollection =
        FirebaseFirestore.instance.collection('passenger_pools');

    // Add a document with auto-generated ID
    poolRequestsCollection.add({
      'passengerName': passengerName,
      'startPoint': GeoPoint(_startPoint!.latitude, _startPoint!.longitude),
      'destinationPoint':
          GeoPoint(_destinationPoint!.latitude, _destinationPoint!.longitude),
      'createdAt': Timestamp.now(), // Add timestamp indicating creation time
      'userId': user.uid, // Add user's UID
    }).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pool requested successfully.'),
        ),
      );
      // Navigate to the DPool page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DPoolPage()),
      );
    }).catchError((error) {
      // Show error message if there is any issue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request pool: $error'),
        ),
      );
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: PassengerPage(),
  ));
}
