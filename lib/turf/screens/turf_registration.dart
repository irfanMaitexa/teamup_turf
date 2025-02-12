import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup_turf/login_screen.dart';
import 'package:teamup_turf/turf/screens/turf_homepage.dart';
import 'package:teamup_turf/turf/services/turf_auth_services.dart';

class TurfRegistrationForm extends StatefulWidget {
  const TurfRegistrationForm({super.key});

  @override
  State<TurfRegistrationForm> createState() => _TurfRegistrationFormState();
}

class _TurfRegistrationFormState extends State<TurfRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _turfNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _fairController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _about = TextEditingController();

  File? _selectedDocument;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  double ? lat;
  double ? long;

  Future<void> register({
    required String turfName, required String location,required String contact,required String address,required String fair,required File documentFile,required String email,required String password})async{
  isLoading = true;
  setState(() {
    
  });
  try{
    String result = await AuthServivices().turfRegister(
      lat:lat ?? 0, long:long ?? 0,about : _about.text,
      turfName: turfName, location: location, contact: contact, address: address, fair: fair, documentUrl: documentFile, email: email, password: password);
    
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseFirestore.instance.collection('turf').doc(userCredential.user!.uid).set({
        'email': email,});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result),)
    ); 
   Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen(role: 'turf',),));

  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()),)
    );
  }finally{
    isLoading = false;
    setState(() {
      
    });

}
  }

  Future<void> _pickDocument() async {
    final XFile? document =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedDocument = File(document!.path);
    });
  }


   Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat =   position.latitude;
      long =   position.longitude;


      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        _locationController.text = address;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Turf Registration"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Turf Name Field
              _buildTextField(
                controller: _turfNameController,
                labelText: "Turf Name",
                icon: Icons.sports_soccer,
                validatorMessage: "Please enter the turf name",
              ),
              const SizedBox(height: 16),
              // Location Field
             GestureDetector(
                onTap: _getCurrentLocation,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _locationController,
                    labelText: "Location",
                    icon: Icons.location_on,
                    validatorMessage: "Please enter the location",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Contact Field
              _buildTextField(
                controller: _contactController,
                labelText: "Contact",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validatorMessage: "Please enter a valid contact number",
              ),
              const SizedBox(height: 16),
              // Address Field
              _buildTextField(
                controller: _addressController,
                labelText: "Gst no",
                icon: Icons.home,
                validatorMessage: "Please enter the address",
              ),
              const SizedBox(height: 16),
              // Fair Field
              _buildTextField(
                controller: _fairController,
                labelText: "Fair",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validatorMessage: "Please enter the fair",
              ),
              _buildTextField(
                controller: _about,
                labelText: "About",
                icon: Icons.attach_money,
                keyboardType: TextInputType.text,
                validatorMessage: "Please enter the fair",
              ),
              const SizedBox(height: 16),
              // Email Field
              _buildTextField(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validatorMessage: "Please enter a valid email",
              ),
              const SizedBox(height: 16),
              // Password Field
              _buildTextField(
                controller: _passwordController,
                labelText: "Password",
                icon: Icons.lock,
                obscureText: true,
                validatorMessage: "Password must be at least 6 characters",
              ),
              const SizedBox(height: 16),
              // Document Upload
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upload Document",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _pickDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white
                    ),
                    child: const Text("Choose File",),
                  ),
                ],
              ),
              if (_selectedDocument != null)
                Text(
                  "Selected File: ${_selectedDocument!.path}",
                  style: const TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:isLoading?Colors.transparent: Colors.green[700],
                  ),
                  onPressed: () async{
                    if (_formKey.currentState!.validate()) {
                      await register(turfName: _turfNameController.text, location: _locationController.text, contact: _contactController.text, address: _addressController.text, fair: _fairController.text, documentFile: _selectedDocument!, email: _emailController.text, password: _passwordController.text);

                      
                    }
                  },
                  child:isLoading? const CircularProgressIndicator(color: Colors.green,): const Text(
                    "Register Turf",
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String validatorMessage,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          maxLines: labelText == 'About' ?  20 : 1,
          minLines: labelText == 'About'  ?   7 : null ,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            prefixIcon: labelText == 'About'? null : Icon(icon),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validatorMessage;
            }
            return null;
          },
        ),
      ),
    );
  }
}
