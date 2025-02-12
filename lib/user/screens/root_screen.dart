import 'package:flutter/material.dart';
import 'package:teamup_turf/user/screens/home_screen.dart';
import 'package:teamup_turf/user/screens/news_screen.dart';
import 'package:teamup_turf/user/screens/profile_view_screen.dart';
import 'package:teamup_turf/user/screens/user_all_turnaments_list.dart';
import 'package:teamup_turf/user/screens/user_bookings_list_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Screens for each BottomNavigationBarItem
  final List<Widget> _screens = [
    const HomeScreen(),
    ProfileViewScreen(),
    const PlayerBookingsScreen(), // Placeholder for the Booking screen
    UserAllTournamentListScreen(team_id: null,), // Placeholder for the Messages screen
    NewsScreen(), // Placeholder for the News screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black for consistency
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black, // Bottom navigation bar background color black
        selectedItemColor: Colors.green, // Selected item color green
        unselectedItemColor: Colors.white, // Unselected item color white
        items: [
          // Customized Bottom Navigation Items
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: 'Booking',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.touch_app),
            label: 'Tournaments',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books),
            label: 'News',
            backgroundColor: Colors.green.shade50,
          ),
        ],
      ),
    );
  }
}
