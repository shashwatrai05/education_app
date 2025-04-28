import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String profilePic;
  DateTime dateOfBirth;  // Removed final to make it mutable
  String phoneNumber;    // Removed final to make it mutable
  String bio;            // Removed final to make it mutable
  List<String> coursesEnrolled; // List of course IDs the user is enrolled in
  List<String> achievements;    // List of achievements (e.g. badges, awards)

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.bio,
    required this.coursesEnrolled,
    required this.achievements,
  });

  // Convert from Firestore map to AppUser model
  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      coursesEnrolled: List<String>.from(map['coursesEnrolled'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  // Convert from AppUser model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'coursesEnrolled': coursesEnrolled,
      'achievements': achievements,
    };
  }

  // Methods to update fields if needed
  void updatePhoneNumber(String newPhone) {
    phoneNumber = newPhone;
  }

  void updateBio(String newBio) {
    bio = newBio;
  }

  void updateCoursesEnrolled(List<String> newCourses) {
    coursesEnrolled = newCourses;
  }

  void updateAchievements(List<String> newAchievements) {
    achievements = newAchievements;
  }
}
