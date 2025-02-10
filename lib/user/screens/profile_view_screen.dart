import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/splash_screen.dart';
import 'package:teamup_turf/turf/services/turf_api_services.dart';
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

  Future<void> createTeam({required String teamName}) async {
    try {
      final result = await UserApiServices().createTeam(teamName: teamName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  TurfApiServices turfApiServices = TurfApiServices();

  Future<String> getLoginId() async {
    final loginid = await LoginServices().getLoginId();
    return loginid!;
  }

  Future<Map<String, dynamic>> fetchPlayerDetails() async {
    String loginId = await getLoginId();
    try {
      return await AdminApiServices().viewSinglePlayer(loginId: loginId);
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
        backgroundColor: Colors.teal, // AppBar color set to teal
        titleTextStyle: TextStyle(color: Colors.white), // White text in AppBar
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white, // White background for the profile view screen
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
                      child: Text('Something went wrong'),
                    );
                  } else {
                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Profile Picture Section with Shadow
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(data['imageUrl'][0]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Edit Button with Light Green Theme
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(playerData: data),
                                ),
                              ).then((success) {
                                if (success == true) {
                                  // Refresh the profile data after editing
                                  setState(() {});
                                }
                              });
                              // Edit button functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.lightGreen, // Light Green button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white, // White text color
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Profile Details Sections
                        _buildInfoRow(
                            Icons.person, 'Username', data['playerName']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        _buildInfoRow(
                            Icons.phone, 'Phone Number', data['mobile']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        // _buildInfoRow(Icons.email, 'Email', ),
                        // const Divider(color: Colors.grey, thickness: 1),
                        // const SizedBox(height: 16),

                        _buildInfoRow(
                            Icons.transgender, 'Gender', data['gender']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        _buildInfoRow(Icons.sports_soccer, 'Preferred Position',
                            data['position']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        _buildInfoRow(Icons.access_time, 'Availability',
                            data['availability']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        _buildInfoRow(
                            Icons.location_on, 'Location', data['location']),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserTeamsScreen(),
                                ));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.groups,
                                  color: Colors.teal), // Green icon
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Your Teams',
                                  style: TextStyle(
                                    fontSize: 16, // Normal text size
                                    fontWeight:
                                        FontWeight.normal, // Normal font weight
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              _showCreateTeamDialog(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.lightGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Create Team',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),


                         Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UserTeamsScreen()));
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.lightGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'My team',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),


                        // _buildInfoRow(Icons.star, 'Experience Level', experienceLevel),
                        // const Divider(color: Colors.grey, thickness: 1),
                        // const SizedBox(height: 24),

                        // Delete Button
                        Center(
                          child: TextButton(
                            onPressed: () {
                              _confirmDeletion(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red, // Red text color
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Create Team Button
                      ],
                    );
                  }
                },
              )),
        ),
      ),
    );
  }

  // Helper method to create info rows with icon, title, and value
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal), // Green icon
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            '$title: $value',
            style: TextStyle(
              fontSize: 16, // Normal text size
              fontWeight: FontWeight.normal, // Normal font weight
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Confirm Deletion Dialog
  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _deleteAccount(); // Call delete account function
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final TextEditingController teamNameController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Team'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: teamNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter team name',
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final teamName = teamNameController.text.trim();
                          if (teamName.isNotEmpty) {
                            setState(() => isLoading = true);
                            await createTeam(teamName: teamName);
                            setState(() => isLoading = false);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Team name cannot be empty'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
