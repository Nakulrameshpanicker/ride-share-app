import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Pools',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DPoolPage(),
    );
  }
}

class DPoolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Driver Pools'),
          backgroundColor: Colors.blue,
        ),
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('driver_pools').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      return PoolListItem(data: data);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PoolListItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const PoolListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver Name: ${data['driverName'] ?? 'N/A'}'),
            Text('Car Model: ${data['carModel'] ?? 'N/A'}'),
            Text('Color: ${data['color'] ?? 'N/A'}'),
            Text('Registration Number: ${data['registrationNumber'] ?? 'N/A'}'),
            Text('Payment Mode: ${data['paymentMode'] ?? 'N/A'}'),
            Text('Amount: ${data['amount'] ?? 'N/A'}'),
            FutureBuilder(
              future: getAddressFromGeoPoint(data['startPoint']),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Start Point: Loading...');
                } else if (snapshot.hasError) {
                  return Text('Start Point: Error fetching address');
                }
                return Text('Start Point: ${snapshot.data ?? 'N/A'}');
              },
            ),
            FutureBuilder(
              future: getAddressFromGeoPoint(data['destinationPoint']),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Destination Point: Loading...');
                } else if (snapshot.hasError) {
                  return Text('Destination Point: Error fetching address');
                }
                return Text('Destination Point: ${snapshot.data ?? 'N/A'}');
              },
            ),
            Text(
                'Created At: ${data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString() : 'N/A'}'),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _acceptPool(data['creatorId'], CommunicationMethod.call);
                  },
                  child: Text('Call'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _acceptPool(data['creatorId'], CommunicationMethod.sms);
                  },
                  child: Text('SMS'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _acceptPool(
                        data['creatorId'], CommunicationMethod.whatsapp);
                  },
                  child: Text('WhatsApp'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to convert GeoPoint to address
  Future<String> getAddressFromGeoPoint(GeoPoint? geoPoint) async {
    if (geoPoint == null) {
      return 'N/A';
    }
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = [
          placemark.name,
          placemark.street,
          placemark.locality,
          placemark.subAdministrativeArea,
          placemark.administrativeArea,
          placemark.postalCode,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        return address.isNotEmpty ? address : 'Unknown Location';
      } else {
        return 'Unknown Location';
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Error fetching address';
    }
  }

  // Function to accept the pool and initiate communication
  void _acceptPool(String? creatorId, CommunicationMethod method) async {
    print('Accept Pool called with creatorId: $creatorId');
    if (creatorId == null) {
      print('Creator ID is null');
      return;
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? phoneNumber = user.phoneNumber;
        print('User phone number: $phoneNumber');
        if (phoneNumber != null) {
          String formattedPhoneNumber = phoneNumber.replaceAll('+', '');
          if (method == CommunicationMethod.call) {
            print('Launching phone dialer');
            await launch('tel:$formattedPhoneNumber');
          } else if (method == CommunicationMethod.sms) {
            print('Launching SMS app');
            await launch('sms:$creatorId');
          } else if (method == CommunicationMethod.whatsapp) {
            print('Launching WhatsApp');
            await launch('https://wa.me/$creatorId');
          }
        } else {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('user_details')
              .doc(creatorId)
              .get();
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?; // Explicit cast
          if (userData != null) {
            String? creatorPhoneNumber = userData['mobile'];
            if (creatorPhoneNumber != null) {
              String formattedCreatorPhoneNumber =
                  creatorPhoneNumber.replaceAll('+', '');
              if (method == CommunicationMethod.call) {
                print('Launching phone dialer');
                await launch('tel:$formattedCreatorPhoneNumber');
              } else if (method == CommunicationMethod.sms) {
                print('Launching SMS app');
                await launch('sms:$creatorPhoneNumber');
              } else if (method == CommunicationMethod.whatsapp) {
                print('Launching WhatsApp');
                await launch('https://wa.me/$creatorId');
              }
            } else {
              print('Creator phone number not found');
            }
          } else {
            print('User details not found for creator ID: $creatorId');
          }
        }
      }
    } catch (e) {
      print('Error accepting pool: $e');
    }
  }
}

enum CommunicationMethod {
  call,
  sms,
  whatsapp,
}
