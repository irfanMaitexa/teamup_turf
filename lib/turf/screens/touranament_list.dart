import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/turf/screens/tournaments_details_screen.dart';
import 'package:teamup_turf/turf/screens/tur_tournament_add_screen.dart';

class TournamentListScreen extends StatefulWidget {

  const TournamentListScreen({Key? key,}) : super(key: key);

  @override
  _TournamentListScreenState createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  List tournaments = [];
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

    final  turfId = await LoginServices().getPlayerId();

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/api/tournament/tournaments-by-turf/${turfId}'));

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
        _showSnackBar('Failed to load tournaments');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      _showSnackBar('Error: Unable to connect');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTournaments,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTournamentScreen(),)).then((value) {
            _fetchTournaments();
            
          },);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error loading tournaments', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchTournaments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : tournaments.isEmpty
                  ? const Center(child: Text('No tournaments found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: tournaments.length,
                      itemBuilder: (context, index) {
                        final tournament = tournaments[index];

                        return GestureDetector(
                          onTap: () {
                            print('jjdjjjd');
                          },
                          child: Card(
                            
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(
                                  tournament['name'][0], // First letter
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                tournament['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('🏆 Prize: ${tournament['prize'] ?? 'N/A'}'),
                                  Text('📅 ${tournament['startDate']} - ${tournament['endDate']}'),
                                  Text('👥 Teams: ${tournament['teams'].length}'),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDetailsScreen(tournamentId: tournament['_id']),));

                                // Navigate to tournament details
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
