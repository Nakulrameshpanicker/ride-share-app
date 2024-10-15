import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

import '../login/account_page.dart';
import '../login/authentication_page.dart'; // Import your authentication page
import '../login/myrides_page.dart';
import '../login/roleselection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _username = '';
  late String _profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('account')
          .doc(user!.uid)
          .get();

      setState(() {
        _username = userData['username'];
        _profileImage = userData['profileImage'] ?? '';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          );
        },
      );

      await Future.delayed(const Duration(seconds: 4));
      Navigator.pop(context);

      await FirebaseAuth.instance.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
      await prefs.remove('email');
      await prefs.remove('password');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthenticationPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error signing out: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Share'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Ride Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Account: $_username',
                style: TextStyle(fontSize: 20),
              ),
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: _profileImage.isNotEmpty
                    ? NetworkImage(_profileImage)
                    : const AssetImage('assets/default_profile_image.jpg')
                        as ImageProvider,
              ),
              onTap: () async {
                final updatedProfileImage = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
                if (updatedProfileImage != null) {
                  setState(() {
                    _profileImage = updatedProfileImage as String;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('My Rides'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyRidesPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/homepage1.jpeg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome to Ride Share',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RoleSelectionPage()),
                    );
                  },
                  child: const Text('Start a Ride'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
