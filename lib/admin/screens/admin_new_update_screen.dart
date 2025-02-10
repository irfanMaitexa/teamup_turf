import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Add intl package for date formatting

import 'package:teamup_turf/admin/screens/admin_news_details_screen.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';

class NewsUpdateScreen extends StatefulWidget {
  @override
  _NewsUpdateScreenState createState() => _NewsUpdateScreenState();
}

class _NewsUpdateScreenState extends State<NewsUpdateScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _selectedImage;
  bool addNewsLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Method to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Method to show the add news dialog
  void _showAddNewsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add News',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(
                  Icons.image,
                  color: Colors.white,
                ),
                label: const Text(
                  "Select Image",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    fixedSize: Size(double.maxFinite, 45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                titleController.clear();
                descriptionController.clear();
                setState(() {
                  _selectedImage = null;
                });
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addNews();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: addNewsLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }

  // Method to add news to the list with current date
  Future<void> _addNews() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        _selectedImage != null) {
      setState(() {
        addNewsLoading = true;
      });

      try {
        final result = await AdminApiServices().addNews(
          title: titleController.text,
          news: descriptionController.text,
          image: _selectedImage!,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() {
          addNewsLoading = false;
        });
      }

      titleController.clear();
      descriptionController.clear();
      _selectedImage = null;
    }
  }

  // Future method to fetch news
  Future<List<dynamic>> _getNews() async {
    return await AdminApiServices().viewNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("News Update", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _getNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No News Available'));
          }

          final newsList = snapshot.data!;
         

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
               String dateString = newsList[index]['submittedAt'];  // Example date string
  
  // Parse the date string
  DateTime date = DateTime.parse(dateString);
  
  // Format the date and time separately
  String formattedDate = DateFormat('yyyy-MM-dd').format(date);  // Format for Date
  String formattedTime = DateFormat('HH:mm:ss').format(date);  // Format for Time
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailsScreen(
                          title: newsList[index]['title'],
                          description: newsList[index]['news'],
                          image: newsList[index]['imageUrl'][0],
                          date: '$formattedDate at $formattedTime',
                          onDelete: () {
                            // Implement delete logic if needed
                          },
                        ),
                      ),
                    );
                  },
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: newsList[index]['imageUrl'][0] != null
                      ? Image.network(
                          newsList[index]['imageUrl'][0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 80, color: Colors.grey),
                  title: Text(
                    newsList[index]['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green),
                  ),
                  subtitle: Text(
                    '$formattedDate at $formattedTime', // Display the date
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade800),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNewsDialog,
        label: const Text("Add News", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }
}
