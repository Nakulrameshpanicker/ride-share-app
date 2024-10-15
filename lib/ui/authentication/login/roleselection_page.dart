import 'package:flutter/material.dart';

import 'driver_page.dart' as driver; // Import DriverPage with alias
import 'passenger_page.dart'; // Import PassengerPage
import 'pool_requests.dart' as pool; // Import PoolRequestsPage with alias

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Selection'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.deepPurple,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Change to back icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back when pressed
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rolepage.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Dim the background by 50%
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Select your Role',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PassengerPage()),
                  );
                },
                child: const Text('Passenger', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Set button size
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => driver.DriverPage()),
                  );
                },
                child: const Text('Driver', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Set button size
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => pool.PoolRequestsPage(
                              userRole: '',
                            )),
                  );
                },
                child:
                    const Text('Active Pools', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // Set button size
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to About Us page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
              child:
                  const Text('About Us', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Color.fromARGB(255, 26, 100, 228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'The Ride Share app, crafted by Nakul Ramesh, an MCA student at ITEC Palayad, offers a convenient solution for individuals seeking to share rides, whether by car or bike. This innovative application facilitates cost-sharing among users, enabling them to split expenses while traveling together. With a user-friendly interface and seamless functionality, Ride Share streamlines the process of organizing shared rides, providing an efficient means of transportation that promotes sustainability and cost-efficiency. Whether commuting to work, attending events, or embarking on road trips, Ride Share empowers users to optimize their travel experience by connecting with fellow passengers, reducing expenses, and contributing to a greener environment.',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 20, color: Color.fromARGB(255, 12, 10, 10)),
        ),
      ),
    );
  }
}
