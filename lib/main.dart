// lib/main.dart
import 'package:education_app/screens/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:education_app/providers/theme_provider.dart';
import 'package:education_app/service/auth_service.dart';
import 'package:education_app/screens/main_nav_screen.dart';
import 'package:education_app/widgets/loading_screen.dart';
import 'package:education_app/themes/app_theme.dart'; // Make sure this import points to your theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Smart Education Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Update according to your theme structure
      darkTheme: AppTheme.darkTheme, // Update according to your theme structure
      themeMode: themeMode,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const LoadingScreen(),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}