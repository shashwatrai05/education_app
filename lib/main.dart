import 'package:education_app/screens/Auth/login.dart';
import 'package:education_app/screens/main_nav_screen.dart';
import 'package:education_app/upload_courses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:education_app/screens/home_screen.dart';
import 'package:education_app/themes/app_theme.dart';
import 'package:education_app/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    // Fetch current user (auto-login)
    final user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Smart Education Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Navigate based on whether the user is logged in
      home: user == null ? const LoginScreen() : const MainNavigationScreen(),
      //home: UploadDummyCoursesScreen(),
    );
  }
}
