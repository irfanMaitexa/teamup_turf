import 'package:flutter/material.dart';


class UserProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: const Text(
          'User Profile will be displayed here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

