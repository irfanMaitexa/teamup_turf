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
            icon: const Icon(Icons.home, color: Colors.green),
            label: 'Home',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, color: Colors.green),
            label: 'Profile',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book, color: Colors.green),
            label: 'Booking',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.touch_app, color: Colors.green),
            label: 'Tournaments',
            backgroundColor: Colors.green.shade50,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books, color: Colors.green),
            label: 'News',
            backgroundColor: Colors.green.shade50,
          ),
        ],
      ),
      // AppBar with gradient and title
     
    );
  }
}
