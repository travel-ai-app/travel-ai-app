import 'package:flutter/material.dart';                            // Βασικό Flutter
import '../../features/trip/my_trips_screen.dart';                 // Η οθόνη MyTrips

/// Κεντρικός Router της εφαρμογής.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {  // Επιλογή route με βάση το name
    switch (settings.name) {
      case '/':                                                    // Αρχική διαδρομή
        return MaterialPageRoute(
          builder: (_) => const MyTripsScreen(),                   // Δείχνουμε MyTripsScreen
        );

      default:                                                     // Αν ζητηθεί άγνωστο route
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),                       // Απλό μήνυμα λάθους
            ),
          ),
        );
    }
  }
}
