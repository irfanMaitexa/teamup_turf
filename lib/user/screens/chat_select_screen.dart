import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_turf/user/screens/messages_screen.dart'; // Import the intl package

class UserSelectionScreen extends StatefulWidget {
  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  // List of users to select from, including the last chat time
  final List<Map<String, dynamic>> users = [
    {'name': 'Alice', 'profilePic': 'https://via.placeholder.com/150', 'lastChatTime': DateTime.now().subtract(Duration(minutes: 10))},
    {'name': 'Bob', 'profilePic': 'https://via.placeholder.com/150', 'lastChatTime': DateTime.now().subtract(Duration(hours: 1))},
    {'name': 'Charlie', 'profilePic': 'https://via.placeholder.com/150', 'lastChatTime': DateTime.now().subtract(Duration(hours: 2))},
    {'name': 'David', 'profilePic': 'https://via.placeholder.com/150', 'lastChatTime': DateTime.now().subtract(Duration(minutes: 30))},
    {'name': 'Eva', 'profilePic': 'https://via.placeholder.com/150', 'lastChatTime': DateTime.now().subtract(Duration(days: 1))},
  ];

  // Variable to hold selected user
  String selectedUser = '';

  // Function to handle user selection
  void _selectUser(String user) {
    setState(() {
      selectedUser = user;
    });
  }

  // Function to format the last chat time
  String _formatLastChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('yMMMd').format(dateTime); // Format as 'Oct 3, 2024' for older dates
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(selectedUser.isNotEmpty ? '$selectedUser' : 'Select a User',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return GestureDetector(
              onTap: () => _selectUser(user['name']!),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(),));
                    },
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePic']!),
                    ),
                    title: Text(
                      user['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Last chat: ${_formatLastChatTime(user['lastChatTime'])}', // Display the formatted last chat time
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: selectedUser == user['name']
                        ? Icon(Icons.check, color: Colors.teal)
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
