import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRidesPage extends StatelessWidget {
  MyRidesPage({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _fetchRides() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    String uid = user.uid;
    QuerySnapshot driverPoolsSnapshot = await _firestore
        .collection('driver_pools')
        .where('uid', isEqualTo: uid)
        .get();
    QuerySnapshot passengerPoolsSnapshot = await _firestore
        .collection('passenger_pool')
        .where('uid', isEqualTo: uid)
        .get();

    List<DocumentSnapshot> allRides = [];
    allRides.addAll(driverPoolsSnapshot.docs);
    allRides.addAll(passengerPoolsSnapshot.docs);

    return allRides;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchRides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching rides'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rides found'));
          }

          List<DocumentSnapshot> rides = snapshot.data!;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> ride =
                  rides[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(ride['name'] ?? 'Unknown Ride'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role: ${ride['role'] ?? 'Unknown'}'),
                    Text(
                        'Amount: \$${(ride['amount'] ?? 0).toStringAsFixed(2)}'),
                    Text('Pickup: ${ride['pickupLocation'] ?? 'Unknown'}'),
                    Text('Drop: ${ride['dropLocation'] ?? 'Unknown'}'),
                    Text('Time Taken: ${ride['timeTaken'] ?? 'Unknown'}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
