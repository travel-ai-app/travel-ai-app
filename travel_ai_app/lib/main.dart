import 'package:flutter/material.dart';
import 'theme/app_theme.dart'; // το κεντρικό theme
import 'ui/screens/root/root_shell.dart'; // το shell με το bottom bar
import 'features/expenses/demo_expenses_screen.dart'; // Demo οθόνη εξόδων
import 'features/trip/demo_trip_overview_screen.dart'; // Demo overview ταξιδιού

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
        home: const DemoTripOverviewScreen(), // Αρχική οθόνη = επισκόπηση ταξιδιού

    );
  }
}