import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/splash_screen.dart';
import 'package:teamup_turf/turf/services/turf_api_services.dart';
import 'package:teamup_turf/user/screens/my_request_screen.dart';
import 'package:teamup_turf/user/screens/user_edit_profile_screen.dart';
import 'package:teamup_turf/user/screens/user_teams_screen.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';


class ProfileViewScreen extends StatefulWidget {
  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  UserApiServices userApiServices = UserApiServices();

  Future<void> _deleteAccount() async {
    try {
      final result = await userApiServices.deletePlayer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> fetchPlayerDetails() async {
    String? loginId = await LoginServices().getLoginId();
    try {
      return await AdminApiServices().viewSinglePlayer(loginId: loginId!);
    } catch (e) {
      throw Exception("Failed to fetch player details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile View'),
        centerTitle: true,
        backgroundColor: Colors.black, // Dark app bar
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black, // Dark background
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FutureBuilder(
                future: fetchPlayerDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong', style: TextStyle(color: Colors.white)),
                    );
                  } else {
                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(data['imageUrl'][0]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(playerData: data),
                                ),
                              ).then((success) {
                                if (success == true) {
                                  setState(() {});
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow(Icons.person, 'Username', data['playerName']),
                        _buildInfoRow(Icons.phone, 'Phone Number', data['mobile']),
                        _buildInfoRow(Icons.transgender, 'Gender', data['gender']),
                        _buildInfoRow(Icons.sports_soccer, 'Preferred Position', data['position']),
                        
                        _buildInfoRow(Icons.location_on, 'Location', data['location']),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserTeamsScreen(),
                                ));
                          },
                          child: _buildClickableRow(Icons.groups, 'Your Teams'),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            final playerId = await LoginServices().getPlayerId();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyRequestScreen(playerId: playerId!,)));
                          },
                          child: _buildClickableRow(Icons.air, 'My request'),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              _confirmDeletion(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              )),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$title: $value',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.white),
      ],
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Confirm Account Deletion', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
