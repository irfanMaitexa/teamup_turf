import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';

class CaptainRequestsScreen extends StatefulWidget {
  final String captainId;
  final List pendingRequests;
  final String teamId;

  CaptainRequestsScreen({super.key, required this.captainId, required this.pendingRequests, required this.teamId});

  @override
  _CaptainRequestsScreenState createState() => _CaptainRequestsScreenState();
}

class _CaptainRequestsScreenState extends State<CaptainRequestsScreen> {
  late List<dynamic> _pendingRequests;
  bool _isLoading = false; // Added loading state

  @override
  void initState() {
    super.initState();
    _pendingRequests = widget.pendingRequests;
  }

  // Function to manage requests (approve/reject)
  Future<void> manageRequest(String playerId, String action) async {
    print('playerId: $playerId, action: $action');
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final url = Uri.parse("$baseUrl/api/team/manage-request");
    final response = await http.post(
      url,
      body: jsonEncode({
        "playerId": playerId,
        "action": action,
        "teamId": widget.teamId,
        "captainId": widget.captainId,
      }),
      headers: {"Content-Type": "application/json"},
    );

    final result = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));

    if (response.statusCode == 200 && action == 'approve') {
      setState(() {
        // _pendingRequests.removeWhere((req) => req['playerId'] == playerId);
      });
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pending Join Requests'),
      ),
      body: _pendingRequests.isEmpty
          ? Center(
              child: Text(
                'No pending requests',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            request['playerName'][0],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['playerName'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Position: ${request['position']}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Mobile: ${request['mobile']}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () async {
                                     final playerId =  request['_id'];

              print(playerId);
                                     print(widget.teamId);
                                     print(widget.captainId);
                                      await manageRequest(playerId!, 'approve');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
