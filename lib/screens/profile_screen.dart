import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/user_model.dart';
import 'package:education_app/models/course_model.dart';
import 'package:education_app/screens/Auth/login.dart';
import 'package:education_app/providers/theme_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> 
    with SingleTickerProviderStateMixin {
  AppUser? _user;
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _achievementsController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  List<Course> _enrolledCourses = [];
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final user = await _firestoreService.getUser(userId);
        
        // Fetch enrolled courses if any
        List<Course> courses = [];
        if (user.coursesEnrolled.isNotEmpty) {
          // Instead of using getUserEnrolledCourses, we'll fetch each course individually
          for (String courseId in user.coursesEnrolled) {
            try {
              // Fetch course details directly from Firestore
              final courseDoc = await FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .get();
                  
              if (courseDoc.exists) {
                courses.add(Course.fromMap(courseDoc.data()!, courseDoc.id));
              }
            } catch (e) {
              print("Error fetching course $courseId: $e");
            }
          }
        }
        
        if (!mounted) return; // Check if widget is still mounted
        
        setState(() {
          _user = user;
          _enrolledCourses = courses;
          _bioController.text = user.bio;
          _phoneController.text = user.phoneNumber;
          _achievementsController.text = user.achievements.join(", ");
          _isLoading = false;
        });
        
        _animationController.forward();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user data: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_user == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = AppUser(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        profilePic: _user!.profilePic,
        dateOfBirth: _user!.dateOfBirth,
        phoneNumber: _phoneController.text,
        bio: _bioController.text,
        coursesEnrolled: _user!.coursesEnrolled,
        achievements: _achievementsController.text.split(", ")
          .where((achievement) => achievement.isNotEmpty)
          .toList(),
      );

      await _firestoreService.updateUser(updatedUser);
      
      if (!mounted) return;
      
      setState(() {
        _user = updatedUser;
        _isEditMode = false;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully"))
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}"))
      );
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _achievementsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Unable to load profile"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Profile" : "Profile"),
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode",
          ),
          
          // Edit/Save button
          if (!_isEditMode)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
              icon: const Icon(Icons.edit),
              tooltip: "Edit Profile",
            )
          else
            IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUserData();
                }
              },
              icon: const Icon(Icons.save),
              tooltip: "Save Changes",
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile header with avatar and basic info
                  _buildProfileHeader(theme, isDarkMode),
                  
                  const SizedBox(height: 24),
                  
                  // User details form
                  if (_isEditMode)
                    _buildEditForm(theme)
                  else
                    _buildProfileInfo(theme, isDarkMode),
                  
                  const SizedBox(height: 16),
                  
                  // Enrolled courses section
                  if (_enrolledCourses.isNotEmpty)
                    _buildCoursesSection(theme, isDarkMode),
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDarkMode) {
    return Hero(
      tag: 'profile-avatar-${_user!.id}',
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Stack(
  alignment: Alignment.bottomRight,
  children: [
    CircleAvatar(
      radius: 60,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
      child: const CircleAvatar(
        radius: 56,
        backgroundImage: NetworkImage(
          "https://png.pngtree.com/thumb_back/fh260/background/20230527/pngtree-an-animated-illustration-that-features-a-young-man-playing-a-game-image_2680953.jpg",
        ),
      ),
    ),
    if (_isEditMode)
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20,
        ),
      ),
  ],
),

            const SizedBox(height: 16),
            Text(
              _user!.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  _user!.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            "Personal Information",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              prefixIcon: Icon(Icons.person_outline),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a short bio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _achievementsController,
            decoration: const InputDecoration(
              labelText: 'Achievements (comma-separated)',
              prefixIcon: Icon(Icons.emoji_events),
              alignLabelWithHint: true,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          title: "Personal Information",
          icon: Icons.person_outline,
          content: Column(
            children: [
              _buildInfoItem(
                icon: Icons.phone,
                label: "Phone Number",
                value: _user!.phoneNumber,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.info_outline,
                label: "Bio",
                value: _user!.bio,
                theme: theme,
              ),
            ],
          ),
          theme: theme,
          isDarkMode: isDarkMode,
        ),
        
        const SizedBox(height: 24),
        
        if (_user!.achievements.isNotEmpty)
          _buildInfoSection(
            title: "Achievements",
            icon: Icons.emoji_events,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _user!.achievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(achievement),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            theme: theme,
            isDarkMode: isDarkMode,
          ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Widget content,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? "Not provided" : value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesSection(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Enrolled Courses",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = _enrolledCourses[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course image
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          image: DecorationImage(
                            image: NetworkImage(course.imageUrl.isNotEmpty 
                                ? course.imageUrl 
                                : "https://placehold.co/600x400/png?text=${course.title}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.level,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Course details
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  course.instructor,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  course.rating.toString(),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}