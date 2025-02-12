import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamup_turf/splash_screen.dart';
import 'package:teamup_turf/turf/screens/touranament_list.dart';
import 'package:teamup_turf/turf/screens/tur_tournament_add_screen.dart';
import 'package:teamup_turf/turf/screens/turf_booking_list_screen.dart';
import 'package:teamup_turf/turf/screens/turf_dateils_page.dart';
import 'package:teamup_turf/turf/screens/turf_review_rating_screen.dart';
import 'package:teamup_turf/turf/screens/turf_user_chat_screen.dart';
import 'package:teamup_turf/turf/turf_chat_new_screen.dart';
import 'package:teamup_turf/uat.dart';

// Sample pages for navigation
class TurfHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turf Management'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(),), (route) => false,);
            },

            child: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16.0, // space between columns
            mainAxisSpacing: 16.0, // space between rows
            childAspectRatio: 1.0, // Equal size for all cards
          ),
          itemCount: 6, // Increased itemCount to include logout card
          itemBuilder: (context, index) {
           
              // Other feature cards
              return _buildFeatureCard(
                context,
                title: _getFeatureTitle(index),
                icon: _getFeatureIcon(index),
                color: _getFeatureColor(index),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => _getFeaturePage(index,context)),
                  );
                },
              );
            }
          
        ),
      ),
    );
  }

  // Returns the title for each feature card
  String _getFeatureTitle(int index) {
    switch (index) {
      case 0:
        return 'Turf Details';
      case 1:
        return 'Bookings';
      case 2:
        return 'Chats';
      case 3:
        return 'Tournaments';
      case 4:
        return 'My Reviews';
     
      default:
        return '';
    }
  }

  // Returns the icon for each feature card
  IconData _getFeatureIcon(int index) {
    switch (index) {
      case 0:
        return Icons.grass;
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.chat;
      case 3:
        return Icons.emoji_events;
      case 4:
        return Icons.reviews;
    
      default:
        return Icons.chat;
    }
  }

  // Returns the color for each feature card (teal for all)
  Color _getFeatureColor(int index) {
    switch (index) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
        return Colors.green; // Set teal color for all cards
      default:
        return Colors.red;
    }
  }

  // Returns the page for each feature card
  Widget _getFeaturePage(int index,BuildContext context) {
    switch (index) {
      case 0:
        return TurfDetailsPage();
      case 1:
        return TurfBookingListsScreen();
      case 2:
        return TurfChatNewScreen(turfId: FirebaseAuth.instance.currentUser!.uid,);
      case 3:
        return TournamentListScreen();
      case 4:
      
     
        return TurfReviewsScreen();
      default:
        return Scaffold();
    }
  }

  // Builds a feature card widget
  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white), // White icon
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the logout card widget
  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Implement logout functionality here
        _showLogoutDialog(context); // Show logout confirmation dialog
      },
      child: Card(
        color: Colors.red, // Red card for logout
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.exit_to_app, size: 48, color: Colors.white), // Exit icon
              const SizedBox(height: 8),
              Text(
                'Logout',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show a confirmation dialog for logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Perform the logout action here, e.g., navigate to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),(route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// Example pages for navigation











