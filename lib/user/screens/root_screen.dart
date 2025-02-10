import 'package:flutter/material.dart';
import 'package:teamup_turf/user/screens/chat_select_screen.dart';
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
    UserAllTournamentListScreen(), // Placeholder for the Messages screen
    NewsScreen(), // Placeholder for the News screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          // Customized Bottom Navigation Items
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, color: Colors.teal),
            label: 'Home',
            backgroundColor: Colors.teal.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, color: Colors.teal),
            label: 'Profile',
            backgroundColor: Colors.teal.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book, color: Colors.teal),
            label: 'Booking',
            backgroundColor: Colors.teal.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.touch_app, color: Colors.teal),
            label: 'Tournaments',
            backgroundColor: Colors.teal.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books, color: Colors.teal),
            label: 'News',
            backgroundColor: Colors.teal.shade50,
          ),
        ],
      ),
      // AppBar with gradient and title
     
    );
  }
}
