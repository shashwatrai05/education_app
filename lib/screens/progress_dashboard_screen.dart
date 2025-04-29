import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/course_model.dart';
import 'package:education_app/models/user_model.dart';
import 'package:education_app/screens/course_detail_screen.dart';
// Remove fl_chart import temporarily
// import 'package:fl_chart/fl_chart.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({Key? key}) : super(key: key);

  @override
  _ProgressDashboardScreenState createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  bool isLoading = true;
  AppUser? currentUser;
  List<Course> enrolledCourses = [];
  Map<String, double> courseProgress = {};
  int completedCourses = 0;
  int totalLessonsCompleted = 0;
  
  // Sample data for charts - in a real app, this would come from Firestore
  // Converted from FlSpot to a simple list of data points
  final List<double> weeklyProgressData = [3, 1, 4, 2, 5, 3, 4];
  final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        // Get user data
        currentUser = await FirestoreService().getUser(userId);
        
        // Get all courses
        final allCourses = await FirestoreService().getCourses();
        
        // Filter enrolled courses
        if (currentUser != null) {
          enrolledCourses = allCourses
              .where((course) => currentUser!.coursesEnrolled.contains(course.id))
              .toList();
              
          // In a real app, this would come from a progress collection in Firestore
          // For now, we'll generate some sample progress data
          for (var course in enrolledCourses) {
            // Random progress between 0 and 1 for demo purposes
            final progress = (course.id.hashCode % 100) / 100;
            courseProgress[course.id] = progress;
            
            if (progress >= 1.0) {
              completedCourses++;
            }
            
            // Calculate completed lessons based on progress (just for demo)
            totalLessonsCompleted += (progress * 10).round(); // Assume 10 lessons per course
          }
        }
        
        setState(() => isLoading = false);
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
              ? _buildNotLoggedInView()
              : enrolledCourses.isEmpty
                  ? _buildNoCoursesEnrolledView()
                  : RefreshIndicator(
                      onRefresh: _loadUserData,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildOverallProgress(),
                          const SizedBox(height: 24),
                          _buildSimpleWeeklyActivityChart(), // Using the simple replacement chart
                          const SizedBox(height: 24),
                          _buildCourseProgressSection(),
                          const SizedBox(height: 24),
                          _buildAchievementsSection(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Not Logged In',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to view your progress dashboard',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCoursesEnrolledView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Courses Enrolled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enroll in courses to track your progress',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to explore courses
            },
            child: const Text('Explore Courses'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    // Calculate overall progress average
    double overallProgress = 0;
    if (courseProgress.isNotEmpty) {
      overallProgress = courseProgress.values.reduce((a, b) => a + b) / courseProgress.length;
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text('Average Progress'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        completedCourses.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Completed Courses'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        totalLessonsCompleted.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const Text('Lessons Completed'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  // Simple replacement for the fl_chart
  Widget _buildSimpleWeeklyActivityChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hours spent learning per day',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  weeklyProgressData.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (weeklyProgressData[index] / 6) * 150,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(weekDays[index]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...enrolledCourses.map((course) => _buildCourseProgressItem(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressItem(Course course) {
    final progress = courseProgress[course.id] ?? 0.0;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  progress >= 1.0 ? Icons.check_circle : Icons.arrow_forward_ios,
                  color: progress >= 1.0 ? Colors.green : Colors.grey,
                  size: progress >= 1.0 ? 24 : 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 6,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    // Sample achievements - in a real app, this would come from user data
    final achievements = [
      {
        'title': 'Fast Learner',
        'description': 'Completed 3 lessons in one day',
        'icon': Icons.speed,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'title': 'Course Master',
        'description': 'Completed your first course',
        'icon': Icons.school,
        'color': Colors.green,
        'unlocked': completedCourses > 0,
      },
      {
        'title': 'Persistent Student',
        'description': 'Studied for 7 days in a row',
        'icon': Icons.calendar_today,
        'color': Colors.purple,
        'unlocked': false,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => _buildAchievementItem(achievement)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final bool unlocked = achievement['unlocked'] as bool;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: unlocked
                ? (achievement['color'] as Color).withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: unlocked ? achievement['color'] as Color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    color: unlocked ? Colors.grey.shade600 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check_circle : Icons.lock_outline,
            color: unlocked ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}