// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return AppBar(
      title: const Text('SmartEdu'),
      actions: [
        IconButton(
          icon: Icon(isDarkMode == ThemeMode.dark
              ? Icons.light_mode
              : Icons.dark_mode),
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
      ],
    );
  }
}