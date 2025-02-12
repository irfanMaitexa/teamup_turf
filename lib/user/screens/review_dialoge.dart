import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamup_turf/baseurl.dart';

class ReviewDialog extends StatefulWidget {
  final String playerId;
  final String turfId;

  ReviewDialog({required this.playerId, required this.turfId});

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _reviewController = TextEditingController();
  double _rating = 1.0;
  bool _isLoading = false;

  Future<void> submitReview() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/review/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'playerId': widget.playerId,
        'turfId': widget.turfId,
        'rating': _rating,
        'review': _reviewController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print('Review added successfully: ${responseData['message']}');
      Navigator.of(context).pop();
    } else {
      print('Failed to add review');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Review and Rating'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'Review'),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 4.0,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _rating > index ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : submitReview,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Submit'),
        ),
      ],
    );
  }
}

void showReviewDialog(BuildContext context, String playerId, String turfId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReviewDialog(playerId: playerId, turfId: turfId);
    },
  );
}
