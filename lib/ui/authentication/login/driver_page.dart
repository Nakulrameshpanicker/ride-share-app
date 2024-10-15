import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ppool.dart'; // Importing PPoolPage

class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? _startPoint;
  LatLng? _destinationPoint;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _driverNameController = TextEditingController();
  TextEditingController _carModelController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _registrationNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _paymentModeController = TextEditingController();
  TextEditingController _startPointController = TextEditingController();
  TextEditingController _destinationPointController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 400,
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
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startPointController,
                  decoration: InputDecoration(
                    labelText: 'Start Point *',
                    labelStyle: TextStyle(color: Colors.red),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () =>
                          _searchLocation(_startPointController.text, true),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Start Point is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _destinationPointController,
                  decoration: InputDecoration(
                    labelText: 'Destination *',
                    labelStyle: TextStyle(color: Colors.red),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _searchLocation(
                          _destinationPointController.text, false),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Destination is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _driverNameController,
                  decoration: InputDecoration(
                    labelText: 'Driver Name *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Driver Name is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _carModelController,
                  decoration: InputDecoration(
                    labelText: 'Car Model *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Car Model is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Color is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _registrationNumberController,
                  decoration: InputDecoration(
                    labelText: 'Registration Number *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Registration Number is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _paymentModeController,
                  decoration: InputDecoration(
                    labelText: 'Mode of Payment *',
                    labelStyle: TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mode of Payment is required';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _createPool,
                child: const Text('Create Pool'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _searchLocation(String locationName, bool isStartPoint) async {
    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        LatLng selectedPoint =
            LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          if (isStartPoint) {
            _startPoint = selectedPoint;
            _startPointController.text = locationName;
          } else {
            _destinationPoint = selectedPoint;
            _destinationPointController.text = locationName;
          }
          _updateMarkers();
          _drawRoute();

          // Move the map camera to the new location
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(selectedPoint, 15),
          );
        });
      } else {
        _showErrorDialog('Location not found');
      }
    } catch (e) {
      print('Error searching location: $e');
      _showErrorDialog('Error searching location');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      if (_startPoint != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('start-location'),
            position: _startPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
      }
      if (_destinationPoint != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('destination-location'),
            position: _destinationPoint!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    });
  }

  void _drawRoute() {
    if (_startPoint != null && _destinationPoint != null) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: [_startPoint!, _destinationPoint!],
          color: Colors.blue,
          width: 3,
        ),
      );
    }
  }

  void _createPool() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_startPoint == null || _destinationPoint == null) {
      _showErrorDialog('Please select both start and destination points.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    Map<String, dynamic> poolData = {
      'driverName': _driverNameController.text,
      'carModel': _carModelController.text,
      'color': _colorController.text,
      'registrationNumber': _registrationNumberController.text,
      'amount': _amountController.text,
      'paymentMode': _paymentModeController.text,
      'startPoint': GeoPoint(_startPoint!.latitude, _startPoint!.longitude),
      'destinationPoint':
          GeoPoint(_destinationPoint!.latitude, _destinationPoint!.longitude),
      'createdAt': Timestamp.now(),
      'creatorId': user.uid,
    };

    try {
      await FirebaseFirestore.instance.collection('driver_pools').add(poolData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pool created successfully!'),
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PPoolPage()),
      );
    } catch (e) {
      print('Error creating pool: $e');
      _showErrorDialog('An error occurred while creating the pool.');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: DriverPage(),
  ));
}
