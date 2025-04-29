import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch User Data
  Future<AppUser> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  // Update User Data
  Future<void> updateUser(AppUser user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  // Create a new User
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Update User Name
  Future<void> updateUserName(String userId, String newName) async {
    await _db.collection('users').doc(userId).update({'name': newName});
  }

  // Real-Time Search Courses
  Future<List<Course>> getCoursesBySearch(String query) async {
    final snapshot = await _db
        .collection('courses')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  // Update Bio
  Future<void> updateBio(String userId, String newBio) async {
    await _db.collection('users').doc(userId).update({'bio': newBio});
  }

  // Update Phone Number
  Future<void> updatePhoneNumber(String userId, String newPhoneNumber) async {
    await _db.collection('users').doc(userId).update({'phoneNumber': newPhoneNumber});
  }

  // Update Courses Enrolled
  Future<void> updateCoursesEnrolled(String userId, List<String> newCourses) async {
    await _db.collection('users').doc(userId).update({'coursesEnrolled': newCourses});
  }

  // Update Achievements
  Future<void> updateAchievements(String userId, List<String> newAchievements) async {
    await _db.collection('users').doc(userId).update({'achievements': newAchievements});
  }

  // Get All Courses
  Future<List<Course>> getCourses() async {
    final snapshot = await _db.collection('courses').get();
    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  // Enroll User in a Course
  Future<void> enrollInCourse(String userId, String courseId) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      List<String> enrolledCourses = List<String>.from(userData?['coursesEnrolled'] ?? []);
      if (!enrolledCourses.contains(courseId)) {
        enrolledCourses.add(courseId);
        await userRef.update({'coursesEnrolled': enrolledCourses});
      }
    }
  }

  // Get Course Recommendations (Simple: based on enrolled courses)
  Future<List<Course>> getRecommendedCourses(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final enrolledCourses = List<String>.from(userData?['coursesEnrolled'] ?? []);

    if (enrolledCourses.isEmpty) return []; // No recommendations if no courses are enrolled

    // Fetch courses the user is enrolled in
    final snapshot = await _db.collection('courses').get();
    final enrolledCourseDocs = snapshot.docs
        .where((doc) => enrolledCourses.contains(doc.id))
        .map((doc) => Course.fromMap(doc.data(), doc.id))
        .toList();

    // Basic recommendation logic
    final recommendedCourses = snapshot.docs
        .map((doc) => Course.fromMap(doc.data(), doc.id))
        .where((course) =>
            !enrolledCourses.contains(course.id) && // Exclude already enrolled courses
            enrolledCourseDocs.any((enrolledCourse) =>
                enrolledCourse.category == course.category)) // Match difficulty
        .toList();

    return recommendedCourses;
  }

  // Get User Enrolled Courses
  Future<List<Course>> getUserEnrolledCourses(List<String> courseIds) async {
    if (courseIds.isEmpty) return [];
    
    List<Course> courses = [];
    
    // Fetch each course by its ID
    for (String courseId in courseIds) {
      try {
        final doc = await _db.collection('courses').doc(courseId).get();
        if (doc.exists) {
          courses.add(Course.fromMap(doc.data()!, doc.id));
        }
      } catch (e) {
        print("Error fetching course $courseId: $e");
      }
    }
    
    return courses;
  }
}