import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_turf/turf/screens/turf_user_chat_screen.dart';

class TurfChatListScreen extends StatelessWidget {
  final String turfId; // Turf ID

  TurfChatListScreen({required this.turfId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users Chat List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('turfId', isEqualTo: turfId) // Get messages for this turf
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var messages = snapshot.data!.docs;
          Set<String> uniqueUsers = {};
          List<Map<String, dynamic>> userList = [];

          for (var doc in messages) {
            String senderId = doc['senderId'];
            if (!uniqueUsers.contains(senderId)) {
              uniqueUsers.add(senderId);
              userList.add({
                'senderId': senderId,
                'senderName': doc['senderName'],
              });
            }
          }

          if (userList.isEmpty) {
            return Center(child: Text("No messages yet."));
          }

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              var user = userList[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(user['senderName']),
                subtitle: Text("Tap to chat"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurfUserListScreen()
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
