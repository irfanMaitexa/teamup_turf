import 'package:flutter/material.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';

class SinglePlayerDetailsScreen extends StatelessWidget {
  final String playerId;

  const SinglePlayerDetailsScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: AdminApiServices().viewSinglePlayer(loginId: playerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            } else {
              final playerDetails = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(playerDetails!['imageUrl'][0]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Player Details
                  Center(
                    child: Text(
                      playerDetails['playerName'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                   Divider(color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  // Details List
                  _buildDetailRow('Mobile', playerDetails['mobile']),
                  _buildDetailRow('Gender', playerDetails['gender']),
                  _buildDetailRow('Position', playerDetails['position']),
                  _buildDetailRow('Availability', playerDetails['availability']),
                  _buildDetailRow('Location', playerDetails['location']),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Call your delete function here
              final result = await AdminApiServices().deletePlayer(id: playerId.toString());
              final success = result['success'];
              if (success) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();  // Go back to the previous screen
              } else {
                // Show an error message if the deletion fails
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
