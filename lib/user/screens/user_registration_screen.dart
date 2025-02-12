import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup_turf/login_screen.dart';
import 'package:teamup_turf/user/services/user_auth_services.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  String? _selectedPosition;
  File? _selectedProfileImage; // Changed from _selectedDocument to _selectedProfileImage
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool _isPasswordVisible = false; // Variable to control password visibility

  final List<String> footballPositions = [
    'Goalkeeper', 'Defender', 'Midfielder', 'Forward'
  ];

  Future<void> _pickProfileImage() async { // Changed from _pickDocument to _pickProfileImage
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedProfileImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final playerName = _playerNameController.text.trim();
    final gender = _selectedGender!;
    final mobile = _mobileController.text.trim();
    final position = _selectedPosition!;
    final location = _locationController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      String result = await UserAuthServices().userRegister(
        playerName: playerName,
        gender: gender,
        mobile: mobile,
        position: position,
        avaialabilty: "default", // Set availability to default
        imageUrl: _selectedProfileImage!, // Changed from _selectedDocument to _selectedProfileImage
        location: location,
        email: email,
        password: password,
      );


       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginScreen(role: 'player')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _playerNameController,
                decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your mobile number' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                items: footballPositions
                    .map((position) => DropdownMenuItem(value: position, child: Text(position)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPosition = value),
                validator: (value) => value == null ? 'Please select your position' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your location' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // Toggle visibility
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Upload Profile Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Changed text
                  ElevatedButton(
                    onPressed: _pickProfileImage, // Changed from _pickDocument to _pickProfileImage
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Choose Image"), // Changed text
                  ),
                ],
              ),
              if (_selectedProfileImage != null) // Changed from _selectedDocument to _selectedProfileImage
                Text("Selected Image: ${_selectedProfileImage!.path}", style: const TextStyle(color: Colors.black54)), // Changed text
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}