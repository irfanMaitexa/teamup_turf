import 'package:flutter/material.dart';

class AdminFeedbackScreen extends StatelessWidget {
  final List<Map<String, dynamic>> feedbacks = [
    {
      'user': 'John Doe',
      'feedback': 'Great app, but the login page has some bugs.',
      'type': 'Error Report',
      'date': '2024-11-01',
    },
    {
      'user': 'Jane Smith',
      'feedback': 'It would be great if you added a dark mode option.',
      'type': 'Suggestion',
      'date': '2024-11-02',
    },
    {
      'user': 'Alice Johnson',
      'feedback': 'App is very smooth. Keep up the good work!',
      'type': 'Suggestion',
      'date': '2024-11-03',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(' Feedback ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            return Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Information
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        SizedBox(width: 16),
                        Text(
                          feedback['user'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Feedback Type (Suggestion or Error Report)
                    Row(
                      children: [
                        Icon(
                          feedback['type'] == 'Suggestion'
                              ? Icons.lightbulb_outline
                              : Icons.report_problem,
                          color: feedback['type'] == 'Suggestion'
                              ? Colors.orange
                              : Colors.red,
                          size: 26,
                        ),
                        SizedBox(width: 10),
                        Text(
                          feedback['type'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Feedback Text
                    Text(
                      feedback['feedback'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 10),

                    // Date of Submission
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Submitted on: ${feedback['date']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),

                    // Action Buttons (optional)
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Resolve Button (Outlined)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Logic for addressing the suggestion or error report
                            },
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            label: Text('Resolve'),
                            style: OutlinedButton.styleFrom(
                              
                              side: BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        // Delete Button (Outlined)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Logic for rejecting or deleting feedback
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text('Delete'),
                            style: OutlinedButton.styleFrom(
                             
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
      ),
    );
  }
}
