import 'package:flutter/material.dart';
import 'package:teamup_turf/admin/screens/admin_home_screen.dart';
import 'package:teamup_turf/login_screen.dart';
import 'package:teamup_turf/turf/screens/turf_homepage.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // // Header Section
              // Container(
              //   padding: EdgeInsets.all(20),
              //   child: Column(
              //     children: [
              //       Text(
              //         'TeamUp Turf',
              //         style: TextStyle(
              //           fontSize: 36,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //           letterSpacing: 2,
              //         ),
              //       ),
              //       SizedBox(height: 10),
              //       Text(
              //         'Choose Your Role to Get Started',
              //         style: TextStyle(
              //           fontSize: 20,
              //           color: Colors.white70,
              //           fontStyle: FontStyle.italic,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Text(
                      'TeamUp Turf',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),

              Text(
                      'Choose Your Role to Get Started',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
              
              
              
              

               Expanded(
                 child: _buildRoleCard(
                        context: context,
                        title: 'User',
                        description: 'Book turfs and join teams effortlessly.',
                        icon: Icons.person,
                        color: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLoginScreen(role: 'player',)),
                          );
                        },
                      ),
               ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _buildRoleCard(
                        context: context,
                        title: 'Admin',
                        description: 'Manage platform data and operations.',
                        icon: Icons.admin_panel_settings,
                        color: Colors.orange,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLoginScreen(role: 'admin',)),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: _buildRoleCard(
                        context: context,
                        title: 'Turf Manager',
                        description: 'Manage bookings and list turfs.',
                        icon: Icons.sports_soccer,
                        color: Colors.purple,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLoginScreen(role: 'turf',)),
                          );
                        },
                      ),
                    ),

             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.white,
          elevation: 10,
          
          shadowColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
           
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  radius: 40,
                  child: Icon(icon, size: 30, color: color),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
