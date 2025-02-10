import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup_turf/admin/services/admin_api_services.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/turf/services/turf_api_services.dart';
import 'package:url_launcher/url_launcher.dart';

class TurfDetailsPage extends StatefulWidget {
  @override
  State<TurfDetailsPage> createState() => _TurfDetailsPageState();
}

class _TurfDetailsPageState extends State<TurfDetailsPage> {
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  TurfApiServices turfApiServices = TurfApiServices();

  Future<String> getLoginId() async {
    final loginid = await LoginServices().getLoginId();
    return loginid!;
  }

  Future<Map<String, dynamic>> fetchTurfDetails() async {
    String loginId = await getLoginId();
    try {
      return await AdminApiServices().getSingleTurf(turfId: loginId);
    } catch (e) {
      throw Exception("Failed to fetch turf details: $e");
    }
  }

  Future<void> editTurf({
    required String id,
    required String turfName,
    required String location,
    required String contact,
    required String address,
    required String fair,
    String? imageUrl,
  }) async {
    try {
      String message = await turfApiServices.updateTurf(
        id: id,
        turfName: turfName,
        location: location,
        contact: contact,
        address: address,
        fair: fair,
        imageUrl: imageUrl??null,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _pickImage(String id) async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
      // Update the image URL directly after picking the image
      await editTurf(
        id: id,
        turfName: "", // Provide required default values or fetch current ones
        location: "",
        contact: "",
        address: "",
        fair: "",
        imageUrl: pickedImage.path, // Update with the new image path
      );
    }
  }

  Future<void> _editProfileDialog({
    required String turfName,
    required String location,
    required String contact,
    required String address,
    required String fair,
    required String id,
    String? imageUrl,
  }) async {
    final TextEditingController turfNameController =
        TextEditingController(text: turfName);
    final TextEditingController locationController =
        TextEditingController(text: location);
    final TextEditingController contactController =
        TextEditingController(text: contact);
    final TextEditingController addressController =
        TextEditingController(text: address);
    final TextEditingController fairController =
        TextEditingController(text: fair);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Turf Name', turfNameController),
              _buildTextField('Location', locationController),
              _buildTextField('Contact', contactController),
              _buildTextField('Address', addressController),
              _buildTextField('Fair', fairController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',style: TextStyle(
              color: Colors.green
            ),),
          ),
          TextButton(

            onPressed: () async {
              await editTurf(
                id: id,
                turfName: turfNameController.text,
                location: locationController.text,
                contact: contactController.text,
                address: addressController.text,
                fair: fairController.text,
                imageUrl: imageUrl??null,
              );
              Navigator.of(context).pop();
              setState(() {
                
              });
            },
            child: const Text('Save',style: TextStyle(
              color: Colors.green
            ),),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turf Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchTurfDetails(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            } else if (snapshots.hasError) {
              return Center(
                child: Text('Something went wrong'),
              );
            } else {
              final data = snapshots.data;
              final id = data!['_id'];
              return Column(
                children: [
                  _buildProfileHeader(
                    context,
                    id,
                    (data['imageUrl'] == null || data['imageUrl'].isEmpty)
                        ? null
                        : data['imageUrl'][0],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDetailRow('Turf Name', data['turfName'] ?? ''),
                        _buildDetailRow('Location', data['location'] ?? ''),
                        _buildDetailRow('Contact', data['contact'] ?? ''),
                        _buildDetailRow('Address', data['address'] ?? ''),
                        _buildDetailRow('Fair', data['fair'] ?? ''),
                        _buildDocumentRow(data['documentUrl'][0] ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _editProfileDialog(
                        id: id,
                        turfName: data['turfName'],
                        location: data['location'],
                        contact: data['contact'],
                        address: data['address'],
                        fair: data['fair'],
                        imageUrl: (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) ? data['imageUrl'][0] : null,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, String id, String? imageUrl) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : (imageUrl != null ? NetworkImage(imageUrl) : null),
          child: _profileImage == null
              ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                )
              : null,
          backgroundColor: Colors.grey[200],
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _pickImage(id),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
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


  Widget _buildDocumentRow(String documentUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _launchUrl(documentUrl),
            child: const Text(
              'View Document',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to launch a URL
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}