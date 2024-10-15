import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool Requests',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Selection'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoolRequestsPage(userRole: 'driver'),
                  ),
                );
              },
              child: Text('I am a Driver'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PoolRequestsPage(userRole: 'passenger'),
                  ),
                );
              },
              child: Text('I am a Passenger'),
            ),
          ],
        ),
      ),
    );
  }
}

class PoolRequestsPage extends StatelessWidget {
  final String userRole;

  PoolRequestsPage({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pool Requests'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Driver Pools:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            PoolList(collection: 'driver_pools', userRole: userRole),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Passenger Pools:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            PoolList(collection: 'passenger_pools', userRole: userRole),
          ],
        ),
      ),
    );
  }
}

// Function to convert GeoPoint to address
Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);
  if (placemarks.isNotEmpty) {
    Placemark placemark = placemarks.first;
    return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
  } else {
    return 'Unknown Location';
  }
}

class PoolList extends StatelessWidget {
  final String collection;
  final String userRole;

  PoolList({required this.collection, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Filter out pool requests that have exceeded the 10-minute limit
        final List<QueryDocumentSnapshot> validDocs =
            snapshot.data!.docs.where((doc) {
          return true; // Return all documents
        }).toList();

        if (validDocs.isEmpty) {
          return Center(child: Text('No active pools right now'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: validDocs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = validDocs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            // Check if any required field is empty or null
            if (collection == 'driver_pools') {
              if (data['driverName'] == null ||
                  data['carModel'] == null ||
                  data['color'] == null ||
                  data['registrationNumber'] == null ||
                  data['startPoint'] == null ||
                  data['destinationPoint'] == null ||
                  data['paymentMode'] == null ||
                  data['amount'] == null) {
                return SizedBox.shrink(); // Return an empty SizedBox
              }
            } else if (collection == 'passenger_pools') {
              if (data['passengerName'] == null ||
                  data['startPoint'] == null ||
                  data['destinationPoint'] == null) {
                return SizedBox.shrink(); // Return an empty SizedBox
              }
            }

            // Check for GeoPoint type and handle conversion
            GeoPoint startGeoPoint = data['startPoint'];
            GeoPoint destinationGeoPoint = data['destinationPoint'];

            return FutureBuilder(
              future: getCurrentUserId(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> userIdSnapshot) {
                if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink(); // Return an empty SizedBox
                } else if (userIdSnapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${userIdSnapshot.error}')); // Show error message
                }

                String currentUser = userIdSnapshot.data!;

                return PoolListItem(
                  startGeoPoint: startGeoPoint,
                  destinationGeoPoint: destinationGeoPoint,
                  collection: collection,
                  data: data,
                  userRole: userRole,
                  currentUser: currentUser,
                );
              },
            );
          },
        );
      },
    );
  }
}

class PoolListItem extends StatefulWidget {
  final GeoPoint startGeoPoint;
  final GeoPoint destinationGeoPoint;
  final String collection;
  final Map<String, dynamic> data;
  final String userRole;
  final String currentUser;

  PoolListItem({
    required this.startGeoPoint,
    required this.destinationGeoPoint,
    required this.collection,
    required this.data,
    required this.userRole,
    required this.currentUser,
  });

  @override
  _PoolListItemState createState() => _PoolListItemState();
}

class _PoolListItemState extends State<PoolListItem> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(minutes: 10), () {
      // After 10 minutes, remove the pool from the UI
      setState(() {
        // Do something to remove the pool from the UI
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
    return FutureBuilder(
      future: Future.wait([
        getAddressFromGeoPoint(widget.startGeoPoint),
        getAddressFromGeoPoint(widget.destinationGeoPoint)
      ]),
      builder:
          (BuildContext context, AsyncSnapshot<List<String>> addressSnapshot) {
        if (addressSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Return an empty SizedBox
        } else if (addressSnapshot.hasError) {
          return Center(
              child: Text(
                  'Error: ${addressSnapshot.error}')); // Show error message
        }

        String startAddress = addressSnapshot.data![0];
        String destinationAddress = addressSnapshot.data![1];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.collection == 'driver_pools') ...[
                    const Text('Driver Pool:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Driver Name: ${widget.data['driverName'] ?? ''}'),
                    Text('Car Model: ${widget.data['carModel'] ?? ''}'),
                    Text('Color: ${widget.data['color'] ?? ''}'),
                    Text(
                        'Registration Number: ${widget.data['registrationNumber'] ?? ''}'),
                    Text('Start Point: $startAddress'),
                    Text('Destination Point: $destinationAddress'),
                    Text('Payment Mode: ${widget.data['paymentMode'] ?? ''}'),
                    Text('Amount: ${widget.data['amount'] ?? ''}'),
                  ],
                  if (widget.collection == 'passenger_pools') ...[
                    const Text('Passenger Pool:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        'Passenger Name: ${widget.data['passengerName'] ?? ''}'),
                    Text('Start Point: $startAddress'),
                    Text('Destination Point: $destinationAddress'),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<String> getCurrentUserId() async {
  String currentUser = ''; // Initialize with empty string
  try {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('user_details')
            .doc('currentUserId')
            .get();
    if (userDoc.exists) {
      currentUser = userDoc.data()!['uid'];
    }
  } catch (e) {
    print('Error getting current user ID: $e');
  }
  return currentUser;
}
