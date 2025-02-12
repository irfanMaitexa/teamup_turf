import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:teamup_turf/baseurl.dart';
import 'package:teamup_turf/user/services/user_api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> playerData;

  const EditProfileScreen({Key? key, required this.playerData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _playerNameController;
  late TextEditingController _mobileController;
  late TextEditingController _genderController;
  late TextEditingController _positionController;
  late TextEditingController _availabilityController;
  late TextEditingController _locationController;

  File? _selectedImage;
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _playerNameController = TextEditingController(text: widget.playerData['playerName']);
    _mobileController = TextEditingController(text: widget.playerData['mobile']);
    _genderController = TextEditingController(text: widget.playerData['gender']);
    _positionController = TextEditingController(text: widget.playerData['position']);
    _availabilityController = TextEditingController(text: widget.playerData['availability']);
    _locationController = TextEditingController(text: widget.playerData['location']);
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _mobileController.dispose();
    _genderController.dispose();
    _positionController.dispose();
    _availabilityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        final response = await updatePlayerWithImage(
          playerId: widget.playerData['_id'],
          playerName: _playerNameController.text,
          mobile: _mobileController.text,
          gender: _genderController.text,
          position: _positionController.text,
          availability: _availabilityController.text,
          location: _locationController.text,
          imageFile: _selectedImage,
        );

        setState(() {
          _isLoading = false; // Stop loading
        });

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Stop loading on error
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (widget.playerData['profileImage'] != null
                              ? NetworkImage(widget.playerData['profileImage'])
                              : const AssetImage('assets/default_profile.png')) as ImageProvider,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _playerNameController,
                    decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your mobile number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _genderController,
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Preferred Position', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _availabilityController,
                    decoration: const InputDecoration(labelText: 'Availability', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) // Show loading indicator when updating
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}


Future<bool> updatePlayerWithImage({
  required String playerId,
  required String playerName,
  required String mobile,
  required String gender,
  required String position,
  required String availability,
  required String location,
  File? imageFile,
}) async {
  final url = Uri.parse('$baseUrl/api/players/$playerId');

  print('Updating Player: $url');

  var request = http.MultipartRequest('PUT', url);
  request.fields['playerName'] = playerName;
  request.fields['mobile'] = mobile;
  request.fields['gender'] = gender;
  request.fields['position'] = position;
  request.fields['availability'] = availability;
  request.fields['location'] = location;

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'imageUrl', // Field name should match backend
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // Adjust based on image type
    ));
  }

  // Send the request
  var response = await request.send();

  // Read response
  String responseBody = await response.stream.bytesToString();
  print('Response Code: ${response.statusCode}');
  print('Response Body: $responseBody');

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to update player: $responseBody');
  }
}
