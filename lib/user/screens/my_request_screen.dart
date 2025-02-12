import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamup_turf/baseurl.dart'; // Ensure this import is correct

class MyRequestScreen extends StatefulWidget {
  final String playerId;

  MyRequestScreen({required this.playerId});

  @override
  _MyRequestScreenState createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> approvedMembers = [];
  List<dynamic> pendingRequests = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/team/all-team'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final teams = data['data'];
          print(teams); // Debugging: Print teams to check the response
          for (var team in teams) {
            final members = team['members'];
            final pending = team['pendingRequests'];

            // Check if the player is in the members list
            if (members.any((member) => member['_id'] == widget.playerId)) {
              approvedMembers.add(team);
            }
            // Check if the player is in the pendingRequests list
            else if (pending.any((request) => request['_id'] == widget.playerId)) {
              pendingRequests.add(team);
            }
          }
        } else {
          errorMessage = data['message'];
        }
      } else {
        errorMessage = 'Failed to load teams: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Set AppBar background to black
        title: Text(
          'Team Details',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green, // Set tab indicator color to green
          labelColor: Colors.green, // Set selected tab text color to green
          unselectedLabelColor: Colors.grey, // Set unselected tab text color to grey
          tabs: [
            Tab(text: 'Approved (${approvedMembers.length})'),
            Tab(text: 'Pending Requests (${pendingRequests.length})'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green)) // Green loading indicator
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white), // Error message in white
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTeamList(approvedMembers),
                    _buildTeamList(pendingRequests),
                  ],
                ),
    );
  }

  Widget _buildTeamList(List<dynamic> teams) {
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No teams found',
          style: TextStyle(color: Colors.white), // No teams message in white
        ),
      );
    }

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          color: Colors.green, // Set Card background to green
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              team['teamName'] ?? 'No Name',
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Captain: ${team['captainId']['name'] ?? 'Unknown'}',
                  style: TextStyle(color: Colors.black), // Set text color to black
                ),
                Text(
                  'Members: ${team['members'].length}',
                  style: TextStyle(color: Colors.black), // Set text color to black
                ),
                Text(
                  'Pending Requests: ${team['pendingRequests'].length}',
                  style: TextStyle(color: Colors.black), // Set text color to black
                ),
              ],
            ),
            onTap: () {
              // Navigate to team details or perform other actions
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}