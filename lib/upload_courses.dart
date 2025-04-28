import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dummy_courses.dart'; // <-- Import your list
import '../models/course_model.dart'; // <-- Import the course model

class UploadDummyCoursesScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UploadDummyCoursesScreen({super.key});

  // Upload the dummy courses to Firestore
  Future<void> uploadCourses() async {
    for (int i = 0; i < dummyCourses.length; i++) {
      final course = dummyCourses[i];
      
      // Automatically generate the document ID for each course
      final courseRef = _db.collection('courses').doc(); // This will auto-generate a unique ID
      await courseRef.set(course.toMap()); // Upload course data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Dummy Courses')),
      body: Center(
        child: ElevatedButton(
          child: Text('Upload Courses to Firestore'),
          onPressed: () async {
            await uploadCourses();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Courses uploaded successfully!')),
            );
          },
        ),
      ),
    );
  }
}
