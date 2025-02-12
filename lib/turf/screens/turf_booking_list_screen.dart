import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';

class TurfBookingListsScreen extends StatefulWidget {
  @override
  _TurfBookingListsScreenState createState() => _TurfBookingListsScreenState();
}

class _TurfBookingListsScreenState extends State<TurfBookingListsScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTurfBookings();
  }

  Future<void> _fetchTurfBookings() async {
    final turfId = await LoginServices().getPlayerId();
    final url = Uri.parse('$baseUrl/api/booking/bookings/turf/$turfId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bookings = data['bookings'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch bookings: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
        _isLoading = false;
      });
    }
  }
Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
  final url = Uri.parse('$baseUrl/api/booking/bookings/$bookingId/status'); // Updated endpoint
  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': 'confirmed'}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated successfully')),
      );
      _fetchTurfBookings(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${response.body}')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${error.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turf Bookings'),
        backgroundColor: Colors.green,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList('pending'),
                    _buildBookingList('confirmed'),
                  ],
                ),
    );
  }

  Widget _buildBookingList(String status) {
    final filteredBookings = _bookings.where((booking) => booking['status'] == status).toList();
    return filteredBookings.isEmpty
        ? Center(child: Text('No $status bookings found.', style: TextStyle(fontSize: 16)))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return Card(
                elevation: 6,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.sports_soccer, color: Colors.green, size: 40),
                        title: Text(
                          booking['turfId']['turfName'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        subtitle: Text('Location: ${booking['turfId']['location']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ),
                      Divider(),
                      Text('Player: ${booking['playerId']['playerName']}', style: TextStyle(fontSize: 14)),
                      Text('Mobile: ${booking['playerId']['mobile']}', style: TextStyle(fontSize: 14)),
                      SizedBox(height: 10),
                      Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookingDate']))}', style: TextStyle(fontSize: 14)),
                      Text('Time: ${booking['startTime']} - ${booking['endTime']}', style: TextStyle(fontSize: 14)),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment: ₹${booking['payment']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            'Status: ${booking['status'].toUpperCase()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: booking['status'] == 'confirmed' ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if(booking['status'] == 'pending')
                      ElevatedButton(
                        onPressed: () {
                          String newStatus = booking['status'] == 'pending' ? 'confirmed' : 'pending';
                          _updateBookingStatus(booking['_id'], newStatus);
                        },
                        child: Text(booking['status'] == 'pending' ? 'Complete' : 'Cancel',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
