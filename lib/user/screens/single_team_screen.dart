import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/turf/screens/touranament_list.dart';
import 'package:teamup_turf/user/screens/turf_list_screen.dart';
import 'package:teamup_turf/user/screens/user_all_turnaments_list.dart';
import 'package:teamup_turf/user/screens/user_request_list_screen.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../baseurl.dart';

class SingleTeamScreen extends StatefulWidget {
  final String id;
  SingleTeamScreen({super.key, required this.id});

  @override
  State<SingleTeamScreen> createState() => _SingleTeamScreenState();
}

class _SingleTeamScreenState extends State<SingleTeamScreen> {
  UserApiServices userApiServices = UserApiServices();
  bool isLoading = false;

  Future<String> currentUser() async {
    final id = await LoginServices().getPlayerId();
    return id.toString();
  }

  Future<Map<String, dynamic>> teamDetails() async {
    try {
      final result = await userApiServices.singleTeam(id: widget.id);
      print('============myteam================');
      print(result);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])));
      return result['data'];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
      return {'message': 'Something went wrong'};
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> joinTeam(String playerId, String teamId) async {
    setState(() => isLoading = true);

    final url = Uri.parse("$baseUrl/api/team/join-team");
    final response = await http.post(
      url,
      body: {
        "playerId": playerId,
        "teamId": teamId,
      },
    );

    setState(() => isLoading = false);

    final result = jsonDecode(response.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: teamDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.lightGreen),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else {
                final data = snapshot.data;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Overview
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group,
                                  size: 32, color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  data!['teamName'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  data['status'].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                backgroundColor:
                                    data['status'].toLowerCase() == 'open'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.date_range, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                formatDate(data['createdAt']),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Team Members
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...data['members'].map((member) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 25,
                              child: Text(
                                member['playerName'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member['playerName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Mobile: ${member['mobile']}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text('Position: ${member['position']}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text(
                                      'Availability: ${member['availability']}',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Team Captain
                    const Text(
                      'Team Captain',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: 25,
                            child: Text(
                              data['captainId']['playerName'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['captainId']['playerName'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Join Team Button
                    FutureBuilder(
                      future: currentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != data['captainId']['_id']) {
                          return ElevatedButton(
                            onPressed:() async{

                              final playerId =  await LoginServices().getPlayerId();
                              print(playerId);
                              await joinTeam(playerId!, widget.id);

                            },
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text('Request'),
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () { 
                                
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CaptainRequestsScreen(captainId: data['captainId']['_id'],pendingRequests: data["pendingRequests"],teamId: data['_id'],),)).then((value) {
                                    setState(() {
                                      teamDetails();
                                    });
                                  },);  
                                 },
                                child: const Text('Manage request',style: TextStyle(color: Colors.white),),
                              ),
                            ),

                             const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TurfsListScreen(),));
              },
              child: const Text('Book Turf', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                // Navigate to book tournament screen
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserAllTournamentListScreen(team_id: data['_id'],),));
              },
              child: const Text('Book Tournament', style: TextStyle(color: Colors.white)),
            ),
          ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
