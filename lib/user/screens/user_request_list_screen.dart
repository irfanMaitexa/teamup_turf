import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';

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
    backgroundColor: Colors.black, // Set background color to black
    appBar: AppBar(
      title: Text('Pending Join Requests'),
      backgroundColor: Colors.green, // AppBar background color
      foregroundColor: Colors.white, // AppBar text color
    ),
    body: _pendingRequests.isEmpty
        ? Center(
            child: Text(
              'No pending requests',
              style: TextStyle(color: Colors.white, fontSize: 18), // Text in white
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
                color: Colors.green, // Set card background to green
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black, // Avatar background in black
                        child: Text(
                          request['playerName'][0],
                          style: TextStyle(color: Colors.white), // Avatar text in white
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request['playerName'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Text in black
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Position: ${request['position']}',
                              style: TextStyle(
                                color: Colors.black, // Text in black
                              ),
                            ),
                            Text(
                              'Mobile: ${request['mobile']}',
                              style: TextStyle(
                                color: Colors.black, // Text in black
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.black) // Loading indicator in black
                              : ElevatedButton(
                                  onPressed: () async {
                                    final playerId = request['_id'];
                                    print(playerId);
                                    print(widget.teamId);
                                    print(widget.captainId);
                                    await manageRequest(playerId!, 'approve');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black, // Button background in black
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Approve',
                                    style: TextStyle(color: Colors.white), // Button text in white
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
