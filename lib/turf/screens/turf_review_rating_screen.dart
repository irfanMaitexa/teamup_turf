import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/login_services.dart';

class TurfReviewsScreen extends StatefulWidget {

 

  @override
  _TurfReviewsScreenState createState() => _TurfReviewsScreenState();
}

class _TurfReviewsScreenState extends State<TurfReviewsScreen> {
  Map<String, dynamic>? reviewData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final plyerId = await LoginServices().getPlayerId();
      final response = await http.get(
        Uri.parse('$baseUrl/api/review/turf/${plyerId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          reviewData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load reviews';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turf Reviews'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : reviewData!['totalReviews'] == 0
                  ? Center(child: Text('No reviews found', style: TextStyle(fontSize: 18)))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Average Rating Section
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Average Rating',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 30),
                                      SizedBox(width: 10),
                                      Text(
                                        reviewData!['averageRating'].toString(),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Based on ${reviewData!['totalReviews']} reviews',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Reviews List
                          Text(
                            'User Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviewData!['reviews'].length,
                            itemBuilder: (context, index) {
                              final review = reviewData!['reviews'][index];
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Player Name and Avatar
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.green,
                                            child: Text(
                                              review['playerId']['playerName'][0],
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            review['playerId']['playerName'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      // Rating
                                      Row(
                                        children: List.generate(
                                          5,
                                          (starIndex) => Icon(
                                            starIndex < review['rating']
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // Review Message
                                      Text(
                                        review['message'] ?? 'No review message',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}