class Course {
  final String id;
  final String title;
  final String description;
  final int duration; // Duration in hours
  final String instructor;
  final String imageUrl;
  final String category;
  final List<String> tags;
  final String level;
  final double rating;
  final int studentsEnrolled;
  final String language;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.instructor,
    required this.imageUrl,
    required this.category,
    required this.tags,
    required this.level,
    required this.rating,
    required this.studentsEnrolled,
    required this.language,
  });

  factory Course.fromMap(Map<String, dynamic> map, String documentId) {
    return Course(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      instructor: map['instructor'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      level: map['level'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      studentsEnrolled: map['studentsEnrolled'] ?? 0,
      language: map['language'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'instructor': instructor,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'level': level,
      'rating': rating,
      'studentsEnrolled': studentsEnrolled,
      'language': language,
    };
  }
}
