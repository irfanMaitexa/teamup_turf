import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/turf/screens/turf_chat_screen.dart';

class TurfUserListScreen extends StatefulWidget {


  TurfUserListScreen();

  @override
  State<TurfUserListScreen> createState() => _TurfUserListScreenState();
}

class _TurfUserListScreenState extends State<TurfUserListScreen> {
  String ?  turfId;

  getTurfId()async{

    turfId = ''  ;

    print(turfId);

    setState(() {
      
    });
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users in"),
        backgroundColor: Colors.green,
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('turfId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var messages = snapshot.data!.docs;
          Set<String> uniqueUsers = {};
          List<Map<String, String>> userList = [];

          for (var message in messages) {
            String senderId = message['senderId'];
            String senderName = message['senderName'];
            if (!uniqueUsers.contains(senderId)) {
              uniqueUsers.add(senderId);
              userList.add({
                'senderId': senderId,
                'senderName': senderName,
              });
            }
          }

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              var user = userList[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(user['senderName']!),
                subtitle: Text("User ID: ${user['senderId']}"),
                onTap: () {
                  // Handle user selection (e.g., navigate to chat)
                  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        receiverId: user['senderId']!,
        receiverName: user['senderName']!,
      ),
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