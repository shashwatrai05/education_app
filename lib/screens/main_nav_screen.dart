// lib/screens/main_nav_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:education_app/providers/theme_provider.dart';
import 'package:education_app/screens/home_screen.dart';
import 'package:education_app/screens/course_screen.dart';
import 'package:education_app/screens/profile_screen.dart';
import 'package:education_app/screens/setting_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  
  final List<Widget> _pages = [
     HomeScreen(),
     CoursesScreen(),
     ProfilePage(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    // If tapping the same tab, don't animate
    if (_currentIndex == index) return;
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _animationController.value)),
            child: Container(
              decoration: BoxDecoration(
                color: theme.bottomNavigationBarTheme.backgroundColor ?? 
                      (isDarkMode ? theme.cardColor : Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: theme.colorScheme.primary,
                  unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.6),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  items: [
                    _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
                    _buildNavItem(Icons.book_rounded, Icons.book_outlined, 'Courses', 1),
                    _buildNavItem(Icons.person_rounded, Icons.person_outlined, 'Profile', 2),
                    _buildNavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings', 3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Icon(
          _currentIndex == index ? activeIcon : inactiveIcon,
          key: ValueKey(_currentIndex == index),
        ),
      ),
      label: label,
    );
  }
}