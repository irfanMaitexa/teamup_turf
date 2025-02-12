import 'package:flutter/material.dart';
import 'package:teamup_turf/admin/screens/single_player_screen.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';

class UserManagementScreen extends StatelessWidget {
  final List<Map<String, String>> users = [
    {
      'name': 'John Doe',
      'photoUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'email': 'john.doe@example.com',
      'contact': '123-456-7890',
      'dob': '1990-05-14',
      'gender': 'Male',
    },
    {
      'name': 'Jane Smith',
      'photoUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'email': 'jane.smith@example.com',
      'contact': '987-654-3210',
      'dob': '1992-08-21',
      'gender': 'Female',
    },
    // Add more users here
  ];

  UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'User management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: FutureBuilder(
            future: AdminApiServices().viewUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.green[800],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong!'),
                );
              } else if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No Users available.'),
                );
              } else {
                final usersList = snapshot.data;
                return ListView.builder(
                  itemCount: usersList!.length,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user['imageUrl'][0]!),
                        ),
                        title: Text(
                          user['playerName']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Contact: ${user['mobile']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Gender: ${user['gender']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SinglePlayerDetailsScreen(
                                playerId: user['loginId'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          )),
    );
  }
}
