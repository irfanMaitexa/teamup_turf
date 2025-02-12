import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/baseurl.dart';
import 'dart:convert';

import 'package:teamup_turf/user/screens/player_turf_details_screen.dart';

class TurfsListScreen extends StatefulWidget {
  @override
  _TurfsListScreenState createState() => _TurfsListScreenState();
}

class _TurfsListScreenState extends State<TurfsListScreen> {
  Future<List<dynamic>> getTurfs({required String status}) async {
    String getTurfsUrl = "$baseUrl/api/register/view-turfs";
    try {
      final response = await http.get(Uri.parse(getTurfsUrl));
      if (response.statusCode == 200) {
        final dataList = jsonDecode(response.body)['data'] as List;
        return dataList.where((turf) => turf['status'] == status).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Turfs"),
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder(
        future: getTurfs(status: 'approved'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.lightGreen),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No turfs found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          } else {
            final data = snapshot.data as List;
            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final turf = data[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerTurfDetailsScreen(
                          turfId: turf['loginId'],
                          timeSlots: [],
                          amenities: ['hi'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              turf['documentUrl'][0],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turf['turfName'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  turf['location'],
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '⚽ +2 sports',
                                  style: TextStyle(fontSize: 14, color: Colors.lightGreen[700]),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                        ],
                      ),
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

