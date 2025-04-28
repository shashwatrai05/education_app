import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/course_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> recommendedCourses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedCourses();
  }

  // Fetch recommended courses based on enrolled courses
  Future<void> _loadRecommendedCourses() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final recommended = await FirestoreService().getRecommendedCourses(userId);
      setState(() {
        recommendedCourses = recommended;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Recommended Courses', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: recommendedCourses.length,
                    itemBuilder: (context, index) {
                      final course = recommendedCourses[index];
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
                              _loadRecommendedCourses(); // Refresh recommendations
                            }
                          },
                          child: const Text('Enroll'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
