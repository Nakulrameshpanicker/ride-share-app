import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class PPoolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pool Page'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('passenger_pools')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No passenger pools available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final poolData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return FutureBuilder<Map<String, dynamic>>(
                future: getLocationData(poolData),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final locationData = snapshot.data!;
                  return PoolListItem(
                    data: poolData,
                    locationData: locationData,
                    onAccept: () async {
                      String? userId = poolData['userId'];
                      if (userId != null) {
                        String? phoneNumber = await getUserPhoneNumber(userId);
                        if (phoneNumber != null) {
                          showCommunicationOptions(context, phoneNumber);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone number not found'),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getLocationData(
      Map<String, dynamic> poolData) async {
    final startLocation = await getAddressFromGeoPoint(poolData['startPoint']);
    final destinationLocation =
        await getAddressFromGeoPoint(poolData['destinationPoint']);
    return {
      'start': startLocation ?? 'Unknown',
      'destination': destinationLocation ?? 'Unknown',
    };
  }

  Future<String?> getAddressFromGeoPoint(GeoPoint? geoPoint) async {
    if (geoPoint == null) return null;
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
        localeIdentifier: 'en_US', // Adjust locale for better results
      );
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        return '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      } else {
        return 'Address not found';
      }
    } catch (e) {
      print('Error fetching address: $e');
      return 'Error fetching address';
    }
  }

  Future<String?> getUserPhoneNumber(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user_details')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return userData['mobile'];
      } else {
        print('User not found with ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  void showCommunicationOptions(BuildContext context, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.call),
              title: Text('Call'),
              onTap: () => launch('tel:$phoneNumber'),
            ),
            ListTile(
              leading: Icon(Icons.sms),
              title: Text('Send SMS'),
              onTap: () => launch('sms:$phoneNumber'),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('WhatsApp'),
              onTap: () => launch('https://wa.me/$phoneNumber'),
            ),
          ],
        );
      },
    );
  }
}

class PoolListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> locationData;
  final VoidCallback onAccept;

  const PoolListItem({
    required this.data,
    required this.locationData,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger Name: ${data['passengerName'] ?? 'N/A'}'),
            Text('Start Point: ${locationData['start'] ?? 'N/A'}'),
            Text('Destination Point: ${locationData['destination'] ?? 'N/A'}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onAccept,
              child: Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PPoolPage(),
  ));
}
