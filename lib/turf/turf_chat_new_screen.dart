import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TurfChatNewScreen extends StatefulWidget {
  final String turfId;
  TurfChatNewScreen({required this.turfId});

  @override
  _TurfChatNewScreenState createState() => _TurfChatNewScreenState();
}

class _TurfChatNewScreenState extends State<TurfChatNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('turfId', isEqualTo: widget.turfId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var messages = snapshot.data!.docs;
          Map<String, String> userMap = {};

          for (var message in messages) {
            userMap[message['senderId']] = message['senderName'];
          }

          var userList = userMap.entries.toList();

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(userList[index].value),
                subtitle: Text("Tap to chat"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurfUserChatScreen(
                        turfId: widget.turfId,
                        userId: userList[index].key,
                        userName: userList[index].value,
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

class TurfUserChatScreen extends StatefulWidget {
  final String turfId;
  final String userId;
  final String userName;

  TurfUserChatScreen({required this.turfId, required this.userId, required this.userName});

  @override
  _TurfUserChatScreenState createState() => _TurfUserChatScreenState();
}

class _TurfUserChatScreenState extends State<TurfUserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('chats').add({
      'turfId': widget.turfId,
      'senderId': widget.turfId, 
      'senderName': "Turf", 
      'receiverId': widget.userId,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.userName}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('turfId', isEqualTo: widget.turfId)
                  .where('senderId', whereIn: [widget.turfId, widget.userId])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == widget.turfId;

                    return ChatBubble(
                      message: message['message'],
                      sender: message['senderName'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String sender;
  final bool isMe;

  ChatBubble({required this.message, required this.sender, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.greenAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.white : Colors.black),
            ),
            SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
