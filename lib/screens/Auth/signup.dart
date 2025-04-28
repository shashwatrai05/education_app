import 'package:education_app/screens/home_screen.dart';
import 'package:education_app/screens/main_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/user_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _passwordController = TextEditingController();

  // Validate password
  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _signUp() async {
    try {
      // Check if all fields are filled
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _bioController.text.isEmpty || _passwordController.text.isEmpty) {
        _showErrorDialog('Please fill all fields');
        return;
      }

      // Validate password
      String? passwordError = _validatePassword(_passwordController.text);
      if (passwordError != null) {
        _showErrorDialog(passwordError);
        return;
      }

      // Create user using FirebaseAuth
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = authResult.user;

      if (user != null) {
        // Create an AppUser object
        final newUser = AppUser(
          id: user.uid,
          name: _nameController.text,
          email: user.email!,
          profilePic: 'default_profile_pic_url', // Use a default pic or pick from user
          dateOfBirth: _selectedDate,
          phoneNumber: _phoneController.text,
          bio: _bioController.text,
          coursesEnrolled: [],
          achievements: [],
        );

        // Store the user data in Firestore
        await FirestoreService().createUser(newUser);

        // Navigate to the Home Screen directly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'An unknown error occurred.';
      }

      // Show error message
      _showErrorDialog(errorMessage);
    } catch (e) {
      print(e.toString());
    }
  }

  // Helper function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            // Date picker for Date of Birth
            ListTile(
              title: Text('Date of Birth: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
