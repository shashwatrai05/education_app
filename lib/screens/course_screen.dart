import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/course_model.dart';
import 'package:education_app/screens/course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> allCourses = [];
  List<Course> filteredCourses = [];
  List<String> categories = [];
  String selectedCategory = 'All';
  String sortBy = 'Popularity'; // Default sort
  bool loading = true;
  List<String> enrolledCourseIds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return; // Check if widget is still mounted
    
    setState(() => loading = true);
    
    // Get user's enrolled courses
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final user = await FirestoreService().getUser(userId);
      enrolledCourseIds = user.coursesEnrolled;
    }
    
    // Get all courses
    final courses = await FirestoreService().getCourses();
    
    if (!mounted) return; // Check again after async operations
    
    setState(() {
      allCourses = courses;
      filteredCourses = courses;
      
      // Extract unique categories
      final uniqueCategories = courses.map((course) => course.category).toSet().toList();
      uniqueCategories.sort();
      categories = ['All', ...uniqueCategories];
      
      loading = false;
    });
  }

  void _filterCourses() {
    if (!mounted) return; // Check if widget is still mounted
    
    if (selectedCategory == 'All') {
      filteredCourses = [...allCourses];
    } else {
      filteredCourses = allCourses
          .where((course) => course.category == selectedCategory)
          .toList();
    }
    
    // Apply search filter if text exists
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredCourses = filteredCourses
          .where((course) => 
              course.title.toLowerCase().contains(searchQuery) ||
              course.description.toLowerCase().contains(searchQuery) ||
              course.instructor.toLowerCase().contains(searchQuery) ||
              course.tags.any((tag) => tag.toLowerCase().contains(searchQuery)))
          .toList();
    }
    
    // Apply sorting
    _sortCourses();
  }

  void _sortCourses() {
    if (!mounted) return; // Check if widget is still mounted
    
    switch (sortBy) {
      case 'Popularity':
        filteredCourses.sort((a, b) => b.studentsEnrolled.compareTo(a.studentsEnrolled));
        break;
      case 'Rating':
        filteredCourses.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Duration: Low to High':
        filteredCourses.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'Duration: High to Low':
        filteredCourses.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case 'Title: A-Z':
        filteredCourses.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    
    if (mounted) { // Check if widget is still mounted before calling setState
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCourses();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _filterCourses();
                  },
                ),
              ),
              
              // Categories and Sort
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Categories dropdown
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        hint: const Text('Category'),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                              _filterCourses();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: sortBy,
                        hint: const Text('Sort by'),
                        items: [
                          'Popularity',
                          'Rating',
                          'Duration: Low to High',
                          'Duration: High to Low',
                          'Title: A-Z',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              sortBy = newValue;
                              _sortCourses();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : filteredCourses.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    final isEnrolled = enrolledCourseIds.contains(course.id);
                    
                    return _buildCourseCard(course, isEnrolled);
                  },
                ),
    );
  }

  Widget _buildCourseCard(Course course, bool isEnrolled) {
    return GestureDetector(
      onTap: () async {
        // Use await and check mounted after navigation completes
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
        
        // Check if widget is still mounted before reloading data
        if (mounted) {
          _loadData();
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            Stack(
              children: [
                Image.network(
                  course.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
                // Level badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          course.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enrolled badge
                if (isEnrolled)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.green.withOpacity(0.8),
                      child: const Center(
                        child: Text(
                          'ENROLLED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Course information
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${course.instructor}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.duration} hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentsEnrolled} students',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Enroll button
                  if (!isEnrolled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            await FirestoreService().enrollInCourse(userId, course.id);
                            if (mounted) { // Check if widget is still mounted
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Enrolled in ${course.title}')),
                              );
                              _loadData(); // Refresh after enrollment
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Enroll'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCategory != 'All'
                ? 'Try changing the category or search term'
                : 'Try a different search term',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                selectedCategory = 'All';
                _filterCourses();
              });
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }
}