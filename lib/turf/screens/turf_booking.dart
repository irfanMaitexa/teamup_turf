import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turf Booking',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TurfListScreen(),
    );
  }
}

class Turf {
  final String name;
  final String location;
  List<Booking> bookings = [];

  Turf({required this.name, required this.location});
}

class Booking {
  final String userName;
  final String timeSlot;

  Booking({required this.userName, required this.timeSlot});
}

class TurfListScreen extends StatelessWidget {
  TurfListScreen({super.key});

  final List<Turf> turfs = [
    Turf(name: 'Turf A', location: 'Location 1'),
    Turf(name: 'Turf B', location: 'Location 2'),
    Turf(name: 'Turf C', location: 'Location 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Available Turfs'),
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: turfs.length,
        itemBuilder: (context, index) {
          final turf = turfs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 6,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Icon(
                Icons.sports_soccer,
                size: 40,
                color: Colors.green,
              ),
              title: Text(
                turf.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                turf.location,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TurfBookingsScreen(turf: turf),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TurfBookingsScreen extends StatelessWidget {
  final Turf turf;
  const TurfBookingsScreen({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings for ${turf.name}'),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Bookings:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Display Bookings
            Expanded(
              child: turf.bookings.isEmpty
                  ? const Center(child: Text('No bookings yet.'))
                  : ListView.builder(
                      itemCount: turf.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = turf.bookings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.green,
                            ),
                            title: Text(
                              booking.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Time Slot: ${booking.timeSlot}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
