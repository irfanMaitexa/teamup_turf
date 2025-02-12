import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class UserTournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;
  final String? teamid;
  const UserTournamentDetailsScreen({
    Key? key,
    required this.tournamentId,
    required this.teamid,
  }) : super(key: key);

  @override
  _UserTournamentDetailsScreenState createState() =>
      _UserTournamentDetailsScreenState();
}

class _UserTournamentDetailsScreenState
    extends State<UserTournamentDetailsScreen> {
  Map<String, dynamic>? tournament;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTournamentDetails();
  }

  Future<void> _fetchTournamentDetails() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tournament/tournament/${widget.tournamentId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tournament = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Widget _buildTournamentInfo() {
    if (tournament == null) return const SizedBox.shrink();

    return Card(
      color: Colors.green, // Set card background to green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament!['name'] ?? 'Unknown Tournament',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set text color to black
              ),
            ),
            const Divider(color: Colors.black), // Set divider color to black
            Text(
              '🏆 Prize: ${tournament!['prize'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black, // Set text color to black
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📅 Date: ${tournament!['startDate']} - ${tournament!['endDate']}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black, // Set text color to black
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurfDetails() {
    if (tournament == null || tournament!['turfId'] == null) {
      return const SizedBox.shrink();
    }
    final turf = tournament!['turfId'];

    return Card(
      color: Colors.green, // Set card background to green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(
          Icons.sports_soccer,
          color: Colors.black, // Set icon color to black
          size: 30,
        ),
        title: Text(
          turf['turfName'] ?? 'Unknown Turf',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Set text color to black
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${turf['location'] ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // Set text color to black
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📞 Contact: ${turf['contact'] ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // Set text color to black
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    if (tournament == null || tournament!['teams'] == null) {
      return const Center(
        child: Text(
          'No teams found',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
      );
    }
    final teams = tournament!['teams'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Teams Participating',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Set text color to white
            ),
          ),
        ),
        const Divider(color: Colors.white), // Set divider color to white
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];

            return Card(
              color: Colors.green, // Set card background to green
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black, // Set avatar background to black
                  child: Text(
                    team['teamName'][0],
                    style: const TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
                title: Text(
                  team['teamName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set text color to black
                  ),
                ),
                subtitle: Text(
                  'Captain: ${team['captainId']['playerName']}',
                  style: const TextStyle(
                    color: Colors.black, // Set text color to black
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black, // Set icon color to black
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _registerTeam() async {
    if (widget.teamid == null) return;

    final url = Uri.parse('$baseUrl/api/tournament/register-team');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tournamentId': widget.tournamentId,
        'teamId': widget.teamid,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team registered successfully')),
      );
      _fetchTournamentDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text(
          'Tournament Details',
          style: TextStyle(color: Colors.white),), // Set text color to white
        backgroundColor: Colors.black, // Set AppBar background to black
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white), // Set icon color to white
            onPressed: _fetchTournamentDetails,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green, // Set loading indicator color to green
              ),
            )
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Failed to load tournament details',
                        style: TextStyle(color: Colors.white), // Set text color to white
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchTournamentDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Set button background to green
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.black), // Set text color to black
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTournamentInfo(),
                      _buildTurfDetails(),
                      _buildTeamsList(),
                      if (widget.teamid != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Set button background to green
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _registerTeam,
                            child: const Text(
                              'Register Team',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black, // Set text color to black
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