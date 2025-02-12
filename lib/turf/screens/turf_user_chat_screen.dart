import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_turf/login_services.dart';

class TurfUserListScreen extends StatefulWidget {


  TurfUserListScreen();

  @override
  State<TurfUserListScreen> createState() => _TurfUserListScreenState();
}

class _TurfUserListScreenState extends State<TurfUserListScreen> {
  String ?  turfId;

  getTurfId()async{

    turfId = await LoginServices().getPlayerId();

    print(turfId);
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users in"),
        backgroundColor: Colors.blueGrey,
      ),
      body:turfId == null ? CircularProgressIndicator()  : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('turfId', isEqualTo: turfId)
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
                },
              );
            },
          );
        },
      ),
    );
  }
}