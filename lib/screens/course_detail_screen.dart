import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/models/course_model.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/user_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  bool isEnrolled = false;
  bool isLoading = true;
  double courseProgress = 0.0;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkEnrollmentStatus();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkEnrollmentStatus() async {
    setState(() => isLoading = true);
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final user = await FirestoreService().getUser(userId);
        final enrolled = user.coursesEnrolled.contains(widget.course.id);
        
        // Get progress data (this would actually come from a progress collection in Firestore)
        // For now, we're just using a placeholder value
        final progress = enrolled ? 0.3 : 0.0; // Example progress value
        
        setState(() {
          isEnrolled = enrolled;
          courseProgress = progress;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking enrollment status: $e')),
        );
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _enrollInCourse() async {
    setState(() => isLoading = true);
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirestoreService().enrollInCourse(userId, widget.course.id);
        
        setState(() {
          isEnrolled = true;
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully enrolled in ${widget.course.title}')),
        );
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling in course: $e')),
        );
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to enroll')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(0.0, 0.0),
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.course.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image, size: 100),
                                ),
                          ),
                          // Dark gradient for better text visibility
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Course stats bar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(Icons.access_time, '${widget.course.duration} hours'),
                              _buildStatItem(Icons.bar_chart, widget.course.level),
                              _buildStatItem(Icons.star, widget.course.rating.toString()),
                              _buildStatItem(Icons.people, '${widget.course.studentsEnrolled} students'),
                            ],
                          ),
                        ),
                        
                        // Progress bar for enrolled users
                        if (isEnrolled)
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Your Progress',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${(courseProgress * 100).round()}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: courseProgress,
                                  backgroundColor: Colors.grey.shade200,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        
                        // Tab bar
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Content'),
                            Tab(text: 'Reviews'),
                          ],
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildContentTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
      bottomNavigationBar: isLoading
          ? null
          : isEnrolled
              ? _buildContinueLearningButton()
              : _buildEnrollButton(),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this course',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.course.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'What you\'ll learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Sample learning outcomes (would come from course data in a real app)
          _buildLearningOutcome('Master the fundamentals of the subject'),
          _buildLearningOutcome('Apply concepts to real-world scenarios'),
          _buildLearningOutcome('Develop practical skills through hands-on exercises'),
          _buildLearningOutcome('Build a portfolio of projects showing your expertise'),
          
          const SizedBox(height: 24),
          const Text(
            'Requirements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Sample requirements (would come from course data in a real app)
          _buildRequirement('Basic understanding of the field'),
          _buildRequirement('Computer with internet connection'),
          _buildRequirement('Willingness to learn and practice'),
          
          const SizedBox(height: 30),
          // Tags section
          const Text(
            'Tags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.course.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningOutcome(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    // Sample course content (would come from course data in a real app)
    final List<Map<String, dynamic>> modules = [
      {
        'title': 'Module 1: Introduction',
        'lessons': [
          {'title': 'Welcome to the Course', 'duration': '5:30', 'isCompleted': true},
          {'title': 'Course Overview', 'duration': '8:45', 'isCompleted': true},
          {'title': 'Getting Started', 'duration': '12:20', 'isCompleted': false},
        ],
      },
      {
        'title': 'Module 2: Core Concepts',
        'lessons': [
          {'title': 'Understanding the Basics', 'duration': '15:10', 'isCompleted': false},
          {'title': 'Key Principles', 'duration': '18:30', 'isCompleted': false},
          {'title': 'Practical Application', 'duration': '22:15', 'isCompleted': false},
          {'title': 'Hands-on Exercise', 'duration': '30:00', 'isCompleted': false},
        ],
      },
      {
        'title': 'Module 3: Advanced Topics',
        'lessons': [
          {'title': 'Advanced Techniques', 'duration': '25:45', 'isCompleted': false},
          {'title': 'Case Studies', 'duration': '20:30', 'isCompleted': false},
          {'title': 'Best Practices', 'duration': '18:20', 'isCompleted': false},
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length,
      itemBuilder: (context, moduleIndex) {
        final module = modules[moduleIndex];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            initiallyExpanded: moduleIndex == 0, // First module expanded by default
            title: Text(
              module['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: (module['lessons'] as List).map<Widget>((lesson) {
              final bool isCompleted = lesson['isCompleted'] as bool;
              return ListTile(
                leading: isCompleted
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  lesson['title'],
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text('Duration: ${lesson['duration']}'),
                enabled: isEnrolled,
                onTap: isEnrolled
                    ? () {
                        // Navigate to lesson content
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening ${lesson['title']}')),
                        );
                      }
                    : null,
                trailing: isEnrolled
                    ? const Icon(Icons.arrow_forward_ios, size: 16)
                    : const Icon(Icons.lock, size: 16),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    // Sample reviews (would come from course data in a real app)
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'John Smith',
        'rating': 5.0,
        'date': '2 weeks ago',
        'comment': 'This course is amazing! I learned so much and the instructor explains everything clearly.',
      },
      {
        'name': 'Sarah Johnson',
        'rating': 4.5,
        'date': '1 month ago',
        'comment': 'Very comprehensive content and great exercises. Would recommend to anyone interested in this subject.',
      },
      {
        'name': 'Mike Brown',
        'rating': 4.0,
        'date': '2 months ago',
        'comment': 'Good course overall. Some sections could go more in-depth but it covers all the basics well.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rating summary
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.course.rating.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.course.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.course.studentsEnrolled} students',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingBar(5, 0.75),
                      _buildRatingBar(4, 0.20),
                      _buildRatingBar(3, 0.05),
                      _buildRatingBar(2, 0.00),
                      _buildRatingBar(1, 0.00),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Reviews list
        ...reviews.map((review) => _buildReviewItem(review)).toList(),
        
        // Add review button (only for enrolled users)
        if (isEnrolled)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review functionality coming soon!')),
                );
              },
              child: const Text('Write a Review'),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    review['name'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      review['rating'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review['comment'],
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _enrollInCourse,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Enroll Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueLearningButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to course content or current lesson
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Continuing where you left off')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}