import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:teamup_turf/baseurl.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  BookingDetailsScreen({required this.bookingId});

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? _booking;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final url = Uri.parse('$baseUrl/api/booking/bookings/${widget.bookingId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _booking = data['booking'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch booking: ${response.statusCode}';
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


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Booking Details'),
      backgroundColor: Colors.green,
      centerTitle: true,
    ),
    backgroundColor: Colors.black, // Set background color to black
    body: _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.green))
        : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
            : _booking == null
                ? Center(child: Text('No booking found.', style: TextStyle(fontSize: 16, color: Colors.white)))
                : SingleChildScrollView(
                    padding: EdgeInsets.all(12), // Reduced padding
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Turf Name
                            Row(
                              children: [
                                Icon(Icons.sports_soccer, color: Colors.black, size: 20), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  _booking!['turfId']['turfName'],
                                  style: TextStyle(
                                    fontSize: 18, // Slightly smaller font
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Location
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Location: ${_booking!['turfId']['location']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Player Name
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Player: ${_booking!['playerId']['playerName']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Mobile
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Mobile: ${_booking!['playerId']['mobile']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Booking Date
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(_booking!['bookingDate']))}',
                                  style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Booking Time
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Time: ${_booking!['startTime']} - ${_booking!['endTime']}',
                                  style: TextStyle(fontSize: 14, color: Colors.black), // Smaller font
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Payment
                            Row(
                              children: [
                                Icon(Icons.payment, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Payment: ₹${_booking!['payment']}',
                                  style: TextStyle(
                                    fontSize: 14, // Smaller font
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced spacing

                            // Status
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.black, size: 18), // Smaller icon
                                SizedBox(width: 6), // Reduced spacing
                                Text(
                                  'Status: ${_booking!['status']}',
                                  style: TextStyle(
                                    fontSize: 14, // Smaller font
                                    color: _booking!['status'] == 'confirmed'
                                        ? Colors.white
                                        : _booking!['status'] == 'cancelled'
                                            ? Colors.white
                                            : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
  );
}
}