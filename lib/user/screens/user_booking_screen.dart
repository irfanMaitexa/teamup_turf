import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamup_turf/baseurl.dart';

import '../../login_services.dart';

class TurfBookingScreen extends StatefulWidget {
  final String turfId;
  final String turfName;
  final double hourlyPrice; // Add hourly price parameter

  TurfBookingScreen({
    required this.turfId,
    required this.turfName,
    required this.hourlyPrice,
  });

  @override
  _TurfBookingScreenState createState() => _TurfBookingScreenState();
}

class _TurfBookingScreenState extends State<TurfBookingScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? selectedPaymentMethod;
  final List<String> paymentMethods = ['UPI', 'Cash', 'Card'];

  late Razorpay _razorpay;
  bool _isLoading = false; // Track loading state
  double _totalCost = 0.0; // Track total cost

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _totalCost = widget.hourlyPrice;
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment successful, proceed to book turf
    _bookTurf();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay() {
    if (_dateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }


    print('666');

    // Calculate total cost
    String timeString = _startTimeController.text; // e.g., "6:53 AM"
DateFormat format = DateFormat("h:mm a"); // Time format for 12-hour AM/PM
DateTime dateTime = format.parse(timeString); // Parse the time string into a DateTime object

final startTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
print('Start Time: $startTime');

String endTimeString = _endTimeController.text; // e.g., "7:45 PM"
DateTime endDateTime = format.parse(endTimeString);

final endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
print('End Time: $endTime');

    final duration = _calculateDuration(startTime, endTime);

    print('Total Duration: $duration hours');
    final totalCost = duration * widget.hourlyPrice;

    setState(() {
      _totalCost = totalCost; // Update total cost
    });

    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu',
      'amount': (_totalCost * 100).toInt(), // Convert to paise
      'name': 'Turf Booking',
      'description': 'Booking for ${widget.turfName}',
      'prefill': {'contact': '1234567890', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    setState(() {
      _isLoading = true; // Start loading
    });

    _razorpay.open(options);
  }

  double _calculateDuration(TimeOfDay startTime, TimeOfDay endTime) {
    final start = DateTime(0, 0, 0, startTime.hour, startTime.minute);
    final end = DateTime(0, 0, 0, endTime.hour, endTime.minute);
    final difference = end.difference(start).inHours;
    return difference.toDouble();
  }

  void _bookTurf() async {
    try {
      final playerId = await LoginServices().getPlayerId();
      final response = await http.post(
        Uri.parse('$baseUrl/api/booking/book_turf'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'turfId': widget.turfId,
          'playerId': playerId, // Replace with actual player ID
          'bookingDate': _dateController.text,
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'payment': _totalCost,
        }),
      );

      setState(() {
        _isLoading = false; // Stop loading
      });



      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Successful!')),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book turf: ${response.body}')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _selectTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.turfName}'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Booking Date', suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: _selectDate,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: InputDecoration(labelText: 'Start Time', suffixIcon: Icon(Icons.access_time)),
                    readOnly: true,
                    onTap: () => _selectTime(_startTimeController),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: InputDecoration(labelText: 'End Time', suffixIcon: Icon(Icons.access_time)),
                    readOnly: true,
                    onTap: () => _selectTime(_endTimeController),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Payment Method'),
              value: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value),
              items: paymentMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Total Cost: ₹${_totalCost.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _openRazorpay,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Book Now', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}