import 'package:flutter/material.dart';
import 'theme/app_theme.dart'; // το κεντρικό theme
import 'ui/screens/root/root_shell.dart'; // το shell με το bottom bar

void main() {
  runApp(const TravelAiApp()); // εκκίνηση της εφαρμογής
}

class TravelAiApp extends StatelessWidget { // root widget
  const TravelAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Travel Companion', // τίτλος app
      debugShowCheckedModeBanner: false, // κρύβει debug banner
      theme: AppTheme.lightTheme, // χρησιμοποιεί το κεντρικό light theme
      home: const RootShell(), // πρώτη οθόνη: το shell με bottom navigation
    );
  }
}