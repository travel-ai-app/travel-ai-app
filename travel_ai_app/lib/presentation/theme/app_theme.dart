import 'package:flutter/material.dart'; // Βασικό Flutter material package για UI

/// Κεντρικά χρώματα της εφαρμογής                     //
class AppColors { // Κλάση που κρατάει όλα τα βασικά χρώματα σαν σταθερές
  static const primary = Color(0xFF2563EB); // Κύριο χρώμα (blue-ish)
  static const primaryDark = Color(0xFF1E3A8A); // Πιο σκούρο του primary
  static const accent = Color(0xFF22C55E); // Accent χρώμα (π.χ. για επιτυχία/confirm)
  static const background = Color(0xFFF9FAFB); // Γενικό background για light mode
  static const surface = Color(0xFFFFFFFF); // Χρώμα επιφανειών (κάρτες, app bars κ.λπ.)
  static const textPrimary = Color(0xFF0F172A); // Κύριο χρώμα κειμένου
  static const textSecondary = Color(0xFF6B7280); // Δευτερεύον κείμενο (υπότιτλοι κ.λπ.)
  static const border = Color(0xFFE5E7EB); // Γραμμές / περιγράμματα
  static const danger = Color(0xFFEF4444); // Χρώμα για λάθη / προειδοποιήσεις
  static const warning = Color(0xFFF59E0B); // Χρώμα για warnings
  static const success = Color(0xFF16A34A); // Επιτυχία / θετικά μηνύματα
}

/// Σταθερές αποστάσεις (spacing) για ομοιόμορφο layout       //
class AppSpacing { // Κλάση με σταθερές για padding/margins
  static const double xs = 4; // Πολύ μικρό κενό
  static const double sm = 8; // Μικρό κενό
  static const double md = 16; // Μεσαίο κενό (default)
  static const double lg = 24; // Μεγάλο κενό
  static const double xl = 32; // Πολύ μεγάλο κενό
}

/// Βασικά text styles για ομοιόμορφη τυπογραφία              //
class AppTextStyles { // Κλάση με κεντρικούς ορισμούς για γραμματοσειρές
  static const heading1 = TextStyle( // Μεγάλος τίτλος (π.χ. ονόματα σελίδων)
    fontSize: 24, // Μέγεθος γραμματοσειράς
    fontWeight: FontWeight.bold, // Έντονη γραφή
    color: AppColors.textPrimary, // Βασικό χρώμα κειμένου
  );

  static const heading2 = TextStyle( // Δεύτερο επίπεδο τίτλου
    fontSize: 20, // Μέγεθος γραμματοσειράς
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColors.textPrimary, // Βασικό κείμενο
  );

  static const body = TextStyle( // Κείμενο παραγράφου
    fontSize: 14, // Κανονικό μέγεθος
    fontWeight: FontWeight.normal, // Κανονικό βάρος
    color: AppColors.textPrimary, // Βασικό χρώμα κειμένου
  );

  static const bodySecondary = TextStyle( // Δευτερεύον κείμενο / υπότιτλοι
    fontSize: 13, // Ελαφρώς μικρότερο
    fontWeight: FontWeight.normal, // Κανονικό
    color: AppColors.textSecondary, // Δευτερεύον χρώμα
  );

  static const caption = TextStyle( // Πολύ μικρό κείμενο (labels κ.λπ.)
    fontSize: 12, // Μικρό μέγεθος
    fontWeight: FontWeight.w400, // Κανονικό
    color: AppColors.textSecondary, // Δευτερεύον
  );
}

/// Κεντρικό Theme της εφαρμογής                              //
class AppTheme { // Κλάση που εκθέτει τα ThemeData για χρήση στο MaterialApp
  /// Light theme (προεπιλογή)                             //
  static ThemeData get light { // Getter που επιστρέφει ThemeData για light mode
    final base = ThemeData.light(); // Ξεκινάμε από το default light ThemeData
    return base.copyWith( // Αντιγράφουμε και τροποποιούμε όπου χρειαζόμαστε
      useMaterial3: true, // Ενεργοποιούμε Material 3
      scaffoldBackgroundColor: AppColors.background, // Χρώμα φόντου για όλες τις σελίδες
      colorScheme: ColorScheme.fromSeed( // Ορίζουμε ColorScheme με βάση ένα seed color
        seedColor: AppColors.primary, // Χρησιμοποιεί το primary σαν βάση
        brightness: Brightness.light, // Light mode
      ),
      appBarTheme: const AppBarTheme( // Ρυθμίσεις για τις AppBar
        elevation: 0, // Χωρίς σκιά
        backgroundColor: AppColors.surface, // Επιφάνεια ίδια με κάρτες
        foregroundColor: AppColors.textPrimary, // Χρώμα τίτλου/εικονιδίων
        centerTitle: false, // Τίτλος αριστερά (τύπου modern apps)
      ),
      cardTheme: CardThemeData( // Default ρυθμίσεις για Card widgets (νέα API)
        color: AppColors.surface, // Λευκό/επιφάνεια
        shape: RoundedRectangleBorder( // Στρογγυλεμένες γωνίες
          borderRadius: BorderRadius.circular(16), // Αρκετά στρογγυλεμένο
        ),
        elevation: 2, // Ελαφριά σκιά
        margin: const EdgeInsets.all(AppSpacing.sm), // Μικρό κενό γύρω από κάθε κάρτα
      ),

      elevatedButtonTheme: ElevatedButtonThemeData( // Default style για ElevatedButton
        style: ElevatedButton.styleFrom( // Χρησιμοποιούμε styleFrom για εύκολη ρύθμιση
          backgroundColor: AppColors.primary, // Primary background
          foregroundColor: Colors.white, // Λευκό κείμενο
          padding: const EdgeInsets.symmetric( // Εσωτερικό padding κουμπιού
            horizontal: 20, // Οριζόντιο
            vertical: 12, // Κάθετο
          ),
          shape: RoundedRectangleBorder( // Σχήμα κουμπιού
            borderRadius: BorderRadius.circular(999), // Πλήρως pill-shaped κουμπί
          ),
          textStyle: const TextStyle( // Default κείμενο κουμπιού
            fontSize: 14, // Μέγεθος
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData( // Default style για TextButton
        style: TextButton.styleFrom( // Ορισμός style
          foregroundColor: AppColors.primary, // Primary χρώμα για text buttons
          textStyle: const TextStyle( // Στυλ γραμματοσειράς
            fontSize: 14, // Μέγεθος
            fontWeight: FontWeight.w500, // Λίγο πιο έντονο από normal
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme( // Default ρυθμίσεις για TextFields
        border: OutlineInputBorder( // Default border
          borderRadius: BorderRadius.circular(12), // Στρογγυλεμένες γωνίες
          borderSide: const BorderSide( // Γραμμή περιγράμματος
            color: AppColors.border, // Απαλό γκρι
          ),
        ),
        enabledBorder: OutlineInputBorder( // Border όταν είναι enabled
          borderRadius: BorderRadius.circular(12), // Στρογγυλεμένες γωνίες
          borderSide: const BorderSide( // Γραμμή
            color: AppColors.border, // Γκρι
          ),
        ),
        focusedBorder: OutlineInputBorder( // Border όταν το TextField έχει focus
          borderRadius: BorderRadius.circular(12), // Γωνίες ίδιες
          borderSide: const BorderSide( // Γραμμή
            color: AppColors.primary, // Μπλε όταν είναι ενεργό
            width: 1.5, // Ελαφρώς πιο χοντρή
          ),
        ),
        contentPadding: const EdgeInsets.symmetric( // Εσωτερικό padding στο TextField
          horizontal: AppSpacing.md, // Οριζόντιο
          vertical: AppSpacing.sm, // Κάθετο
        ),
      ),
    );
  }

  /// Dark theme placeholder (θα το φτιάξουμε σωστά αργότερα) //
  static ThemeData get dark { // Getter για dark ThemeData
    final base = ThemeData.dark(); // Ξεκινάμε από default dark
    return base.copyWith( // Προσωρινές μικρές αλλαγές
      useMaterial3: true, // Material 3 και εδώ
      colorScheme: ColorScheme.fromSeed( // Color scheme για dark mode
        seedColor: AppColors.primaryDark, // Πιο σκούρο primary
        brightness: Brightness.dark, // Dark mode
      ),
    );
  }
}
