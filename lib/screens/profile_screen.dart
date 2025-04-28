import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/user_model.dart';
import 'package:education_app/models/course_model.dart';
import 'package:education_app/screens/Auth/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppUser? _user;
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _coursesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final user = await FirestoreService().getUser(userId);
      setState(() {
        _user = user;
        _bioController.text = user.bio;
        _phoneController.text = user.phoneNumber;
        _achievementsController.text = user.achievements.join(", ");
        _coursesController.text = user.coursesEnrolled.join(", ");
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_user == null) return;

    final updatedUser = AppUser(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      profilePic: _user!.profilePic,
      dateOfBirth: _user!.dateOfBirth,
      phoneNumber: _phoneController.text,
      bio: _bioController.text,
      coursesEnrolled: _coursesController.text.split(", ").toList(),
      achievements: _achievementsController.text.split(", ").toList(),
    );

    await FirestoreService().updateUser(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://png.pngtree.com/thumb_back/fh260/background/20230527/pngtree-an-animated-illustration-that-features-a-young-man-playing-a-game-image_2680953.jpg"),
              ),
              Text(_user!.name, style: Theme.of(context).textTheme.titleLarge),
              Text(_user!.email),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your bio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _achievementsController,
                decoration: const InputDecoration(labelText: 'Achievements (comma-separated)'),
              ),
              TextFormField(
                controller: _coursesController,
                decoration: const InputDecoration(labelText: 'Courses Enrolled (comma-separated)'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserData();
                  }
                },
                child: const Text("Update Profile"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
