import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class AllTournamentListScreen extends StatefulWidget {
  const AllTournamentListScreen({Key? key}) : super(key: key);

  @override
  _AllTournamentListScreenState createState() => _AllTournamentListScreenState();
}

class _AllTournamentListScreenState extends State<AllTournamentListScreen> {
  List<dynamic> tournaments = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tournament/all-tournaments'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tournaments = data['data'];
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

  Widget _buildTournamentCard(dynamic tournament) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament['name'] ?? 'Unknown Tournament',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text('🏆 Prize: ${tournament['prize'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            Text(
                '📅 Date: ${tournament['startDate']} - ${tournament['endDate']}',
                style: const TextStyle(fontSize: 16)),
            const Divider(),
            if (tournament['turfId'] != null)
              ListTile(
                leading: const Icon(Icons.sports_soccer, color: Colors.teal),
                title: Text(
                  tournament['turfId']['turfName'] ?? 'Unknown Turf',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    '${tournament['turfId']['location'] ?? ''}\n📞 Contact: ${tournament['turfId']['contact'] ?? ''}'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tournaments'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTournaments,
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
                      const Text('Failed to load tournaments',
                          style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchTournaments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : tournaments.isEmpty
                  ? const Center(
                      child: Text('No tournaments found',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: tournaments.length,
                      itemBuilder: (context, index) {
                        return _buildTournamentCard(tournaments[index]);
                      },
                    ),
    );
  }
}
