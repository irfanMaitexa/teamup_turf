import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentDetailsScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  _TournamentDetailsScreenState createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Divider(),
            Text('🏆 Prize: ${tournament!['prize'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('📅 Date: ${tournament!['startDate']} - ${tournament!['endDate']}',
                style: const TextStyle(fontSize: 16)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(Icons.sports_soccer, color: Colors.teal, size: 30),
        title: Text(turf['turfName'] ?? 'Unknown Turf', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${turf['location'] ?? ''}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('📞 Contact: ${turf['contact'] ?? ''}', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    if (tournament == null || tournament!['teams'] == null) {
      return const Center(child: Text('No teams found'));
    }
    final teams = tournament!['teams'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Teams Participating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(team['teamName'][0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(team['teamName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Captain: ${team['captainId']['playerName']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Details'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTournamentDetails,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load tournament details',
                          style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchTournamentDetails,
                        child: const Text('Retry'),
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
                    ],
                  ),
                ),
    );
  }
}
