import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const ToteTraxApp());
}

class ToteTraxApp extends StatelessWidget {
  const ToteTraxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToteTrax',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
