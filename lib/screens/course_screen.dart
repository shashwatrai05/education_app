import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/course_model.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> courses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final allCourses = await FirestoreService().getCourses();
    setState(() {
      courses = allCourses;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Courses")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  leading: Image.network(course.imageUrl, width: 50, height: 50),
                  title: Text(course.title),
                  subtitle: Text(course.instructor),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        await FirestoreService().enrollInCourse(userId, course.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enrolled in ${course.title}')));
                      }
                    },
                    child: const Text('Enroll'),
                  ),
                );
              },
            ),
    );
  }
}
