import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../screens/course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            course.imageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructor: ${course.instructor}', style: TextStyle(color: Colors.grey[600])),
            Text('Duration: ${course.duration} hours', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Implement enrollment functionality here
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Enroll', style: TextStyle(fontSize: 12)),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CourseDetailScreen(course: course),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                final tween = Tween(begin: begin, end: end);
                final fadeAnimation = animation.drive(tween);

                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
