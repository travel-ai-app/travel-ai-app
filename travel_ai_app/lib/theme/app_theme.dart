import 'package:flutter/material.dart'; // βασικό πακέτο για UI

class AppTheme { // κλάση που κρατά όλα τα themes του app
  static ThemeData get lightTheme { // βασικό light theme
    return ThemeData( // αντικείμενο ThemeData
      useMaterial3: true, // Material 3
      colorScheme: ColorScheme.fromSeed( // παλέτα χρωμάτων
        seedColor: Colors.blue, // βασικό χρώμα (θα το αλλάξουμε εύκολα μετά)
      ),
      scaffoldBackgroundColor: Colors.grey[100], // default φόντο για όλες τις οθόνες
      textTheme: const TextTheme( // βασικά στυλ για κείμενα
        titleLarge: TextStyle( // για μεγάλους τίτλους (π.χ. AI Travel Companion)
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle( // για κείμενα σώματος (π.χ. welcome text)
          fontSize: 16,
        ),
      ),
    ); // τέλος ThemeData
  } // τέλος lightTheme
} // τέλος AppTheme