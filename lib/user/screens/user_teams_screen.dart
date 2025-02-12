import 'package:flutter/material.dart';
import 'package:teamup_turf/user/screens/single_team_screen.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';

class UserTeamsScreen extends StatefulWidget {
  const UserTeamsScreen({super.key});

  @override
  State<UserTeamsScreen> createState() => _UserTeamsScreenState();
}

class _UserTeamsScreenState extends State<UserTeamsScreen> {
  UserApiServices userApiServices = UserApiServices();

  Future<List<dynamic>> _getTeams() async {
    return await userApiServices.getCreatedTeams();
  }

  Future<void> deleteTeam({required String id}) async {
    try {
      final result = await userApiServices.deleteTeam(id: id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
    ).then((value) {
      setState(() {
        
      });
    },);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Teams'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _getTeams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No teams yet'));
                  } else {
                    final data = snapshot.data;
                    return ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SingleTeamScreen(id: data[index]['_id']),
                              ),
                            );
                          },
                          child: TeamCard(
                            title: data[index]['teamName'],
                            description: data[index]['status'],
                            onDelete: () => deleteTeam(id: data[index]['_id']),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showCreateTeamDialog(context);
                    // Add your button action here
                  },
                  child: const Text(
                    'Create New Team',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  
}






class TeamCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDelete;

  const TeamCard({
    required this.title,
    required this.description,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: $description',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
