import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/user/screens/single_news_screen.dart';

class NewsScreen extends StatelessWidget {
  Future<List<dynamic>> _getNews() async {
    return await AdminApiServices().viewNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text(
          'News',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // Set AppBar background to black
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _getNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green, // Set loading indicator color to green
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
              );
            } else if (snapshot.data!.isEmpty || !snapshot.hasData) {
              return Center(
                child: Text(
                  'No news yet',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
              );
            } else {
              final data = snapshot.data;
              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  String dateString = data[index]['submittedAt']; // Example date string

                  // Parse the date string
                  DateTime date = DateTime.parse(dateString);

                  // Format the date and time separately
                  String formattedDate = DateFormat('yyyy-MM-dd').format(date); // Format for Date
                  String formattedTime = DateFormat('HH:mm:ss').format(date);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserNewsDetailsScreen(
                            title: data[index]['title'],
                            description: data[index]['news'],
                            date: '$formattedDate at $formattedTime',
                            image: data[index]['imageUrl'][0],
                          ),
                        ),
                      );
                    },
                    child: NewsCard(
                      title: data[index]['title']!,
                      description: data[index]['news']!,
                      imageUrl: data[index]['imageUrl'][0]!,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const NewsCard({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green, // Set card background to green
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set text color to black
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black, // Set text color to black
                    ),
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