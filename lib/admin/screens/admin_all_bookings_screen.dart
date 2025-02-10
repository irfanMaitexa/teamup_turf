import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamup_turf/user/screens/user_booking_details_screen.dart';


class AllBookingsScreen extends StatefulWidget {
  @override
  _AllBookingsScreenState createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final response = await http.get(Uri.parse('YOUR_API_URL_HERE'));
    if (response.statusCode == 200) {
      setState(() {
        bookings = jsonDecode(response.body)['bookings'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load bookings')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Bookings'), backgroundColor: Colors.lightGreen),
      body: Container(
        color: Colors.lightGreen[50],
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return GestureDetector(
                    onTap: () {
                       Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsScreen(bookingId: booking['_id']),
                              ),
                            );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      color: Colors.lightGreen[100],
                      child: ListTile(
                        leading: Icon(Icons.sports_soccer, color: Colors.green),
                        title: Text(
                          booking['turfId']['turfName'],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]),
                        ),
                        subtitle: Text(
                          '${booking['turfId']['location']}\nPlayer: ${booking['playerId']['playerName']}\nMobile: ${booking['playerId']['mobile']}',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[900]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
