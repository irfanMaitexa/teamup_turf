import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // List of messages
  final List<String> messages = [
    'Hello! How are you?',
    'I am good, thanks! What about you?',
    'I\'m doing great, just working on some projects.',
    'That sounds awesome! Keep it up!',
  ];

  // Controller for the message input field
  final TextEditingController _controller = TextEditingController();

  // Function to add a new message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(_controller.text); // Add the message to the list
      });
      _controller.clear(); // Clear the input field after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message List Section
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return MessageCard(message: messages[index]);
                },
              ),
            ),
            // Message Input Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Text field to type a message
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display individual messages
class MessageCard extends StatelessWidget {
  final String message;

  const MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
