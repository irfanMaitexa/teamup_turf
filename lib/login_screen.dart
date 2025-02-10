import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teamup_turf/admin/screens/admin_home_screen.dart';
import 'package:teamup_turf/login_services.dart';
import 'package:teamup_turf/turf/screens/turf_homepage.dart';
import 'package:teamup_turf/turf/screens/turf_registration.dart';
import 'package:teamup_turf/user/screens/root_screen.dart';
import 'package:teamup_turf/user/screens/user_registration_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  String role;

  AdminLoginScreen({super.key, required this.role});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true; // State to track password visibility

  // Method to simulate login action
  void _login() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        final message = await LoginServices()
            .login(email: _emailController.text, password: _passwordController.text);
        final role = message['role'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message['message'])),
        );
        if (role == 'player') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else if (role == 'turf') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TurfHomePage()));
        } else if (role == 'admin') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHomeScreen()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(
                    widget.role == 'admin'
                        ? Icons.admin_panel_settings
                        : widget.role == 'player'
                            ? Icons.person
                            : Icons.sports_soccer,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                SizedBox(height: 40),

                // Title
                Text(
                  widget.role == 'admin'
                      ? 'Admin Login'
                      : widget.role == 'player'
                          ? 'User Login'
                          : 'Turf Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 20),

                // Email Text Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Text Field with show/hide functionality
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Toggle password visibility
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Signup navigation
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Signup',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.role == 'player'
                                ? Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => UserRegistrationScreen()))
                                : Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => TurfRegistrationForm()));
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
