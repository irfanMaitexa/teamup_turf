import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/user/screens/user_booking_details_screen.dart';

class PlayerBookingsScreen extends StatefulWidget {
  const PlayerBookingsScreen({super.key});

  @override
  _PlayerBookingsScreenState createState() => _PlayerBookingsScreenState();
}

class _PlayerBookingsScreenState extends State<PlayerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final playerId = await LoginServices().getPlayerId();
    final url = Uri.parse('$baseUrl/api/booking/bookings/player/$playerId');

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




  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text('My Bookings'),
      backgroundColor: Colors.green,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          color: Colors.green, // Set TabBar background to black
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white, // Indicator color
            labelColor: Colors.black, // Selected tab text color
            unselectedLabelColor: Colors.grey, // Unselected tab text color
            tabs: [
              Tab(
                icon: Icon(Icons.schedule, color: Colors.black), // Tab icon color
                text: 'Ongoing',
              ),
              Tab(
                icon: Icon(Icons.check_circle, color: Colors.black), // Tab icon color
                text: 'Completed',
              ),
            ],
          ),
        ),
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
  List<dynamic> filteredBookings = _bookings.where((booking) => booking['status'] == status).toList();

  if (filteredBookings.isEmpty) {
    return Center(child: Text('No $status bookings found.', style: TextStyle(fontSize: 16, color: Colors.white)));
  }

  return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: filteredBookings.length,
    itemBuilder: (context, index) {
      final booking = filteredBookings[index];
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
          color: Colors.green, // Set Card background to green
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['turfId']['turfName'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Icon(
                      booking['status'] == 'ongoing' ? Icons.schedule : Icons.check_circle,
                      color: Colors.black, // Set icon color to black
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.black), // Set icon color to black
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        booking['turfId']['location'],
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.black), // Set icon color to black
                    SizedBox(width: 5),
                    Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookingDate'])),
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.black), // Set icon color to black
                    SizedBox(width: 5),
                    Text(
                      '${booking['startTime']} - ${booking['endTime']}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.money, size: 18, color: Colors.black), // Set icon color to black
                    SizedBox(width: 5),
                    Text(
                      '₹${booking['payment']}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}










  // Widget _buildBookingList(String status) {
  //   List<dynamic> filteredBookings = _bookings.where((booking) => booking['status'] == status).toList();
    
  //   if (filteredBookings.isEmpty) {
  //     return Center(child: Text('No $status bookings found.', style: TextStyle(fontSize: 16)));
  //   }
    
  //   return ListView.builder(
  //     padding: EdgeInsets.all(16),
  //     itemCount: filteredBookings.length,
  //     itemBuilder: (context, index) {
  //       final booking = filteredBookings[index];
  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => BookingDetailsScreen(bookingId: booking['_id']),
  //             ),
  //           );
  //         },
  //         child: Card(
  //           color: Colors.white,
  //           elevation: 4,
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //           margin: EdgeInsets.only(bottom: 16),
  //           child: Padding(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       booking['turfId']['turfName'],
  //                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
  //                     ),
  //                     Icon(
  //                       booking['status'] == 'ongoing' ? Icons.schedule : Icons.check_circle,
  //                       color: booking['status'] == 'ongoing' ? Colors.orange : Colors.green,
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.location_on, size: 18, color: Colors.grey),
  //                     SizedBox(width: 5),
  //                     Expanded(
  //                       child: Text(
  //                         booking['turfId']['location'],
  //                         style: TextStyle(fontSize: 14, color: Colors.grey[700]),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.calendar_today, size: 18, color: Colors.grey),
  //                     SizedBox(width: 5),
  //                     Text(
  //                       DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookingDate'])),
  //                       style: TextStyle(fontSize: 14),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.access_time, size: 18, color: Colors.grey),
  //                     SizedBox(width: 5),
  //                     Text(
  //                       '${booking['startTime']} - ${booking['endTime']}',
  //                       style: TextStyle(fontSize: 14),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Icon(Icons.money, size: 18, color: Colors.grey),
  //                     SizedBox(width: 5),
  //                     Text(
  //                       '₹${booking['payment']}',
  //                       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


}
