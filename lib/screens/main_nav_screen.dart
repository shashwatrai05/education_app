import 'package:education_app/screens/course_screen.dart';
import 'package:education_app/screens/home_screen.dart';
import 'package:education_app/screens/profile_screen.dart';
import 'package:education_app/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:education_app/widgets/bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
     HomeScreen(),
    CoursesScreen(),
     ProfilePage(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
