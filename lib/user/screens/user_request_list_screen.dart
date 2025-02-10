import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

class CaptainRequestsScreen extends StatefulWidget {
  final String captainId;  // Pass the captain ID from the previous screen

  CaptainRequestsScreen({required this.captainId});

  @override
  _CaptainRequestsScreenState createState() => _CaptainRequestsScreenState();
}

class _CaptainRequestsScreenState extends State<CaptainRequestsScreen> {
  late Future<List<dynamic>> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _pendingRequests = fetchPendingRequests(widget.captainId);
  }

  // Fetch pending join requests from the API
  Future<List<dynamic>> fetchPendingRequests(String captainId) async {

    final response = await http.get(
      Uri.parse('$baseUrl/api/team/captain-requests/$captainId'),
    );

    print(response.body);
    print('===========================');

    if (response.statusCode == 200) {
      // Parse the response body and return the list of requests
      final data = json.decode(response.body);
      if (data['success']) {
        return List<dynamic>.from(data['data']);
      } else {
        throw Exception('Failed to load pending requests');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Function to handle the action (approve or reject)
  Future<void> handleRequest(String action, String playerId, String teamId) async {
    final response = await http.post(
      Uri.parse('https://your-api-url.com/manage-request'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'playerId': playerId,
        'action': action,
        'teamId': teamId,
        'captainId': widget.captainId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        setState(() {
          // Refresh the requests list after the action
          _pendingRequests = fetchPendingRequests(widget.captainId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update request')));
      }
    } else {
      throw Exception('Failed to handle request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Join Requests'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pendingRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending requests'));
          } else {
            final requests = snapshot.data!;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(request['playerName'][0], style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(request['playerName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Position: ${request['position']}\nMobile: ${request['mobile']}'),
                    isThreeLine: true,
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => handleRequest('approve', request['_id'], request['teamId']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Approve button color
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Approve'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => handleRequest('reject', request['_id'], request['teamId']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Reject button color
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
