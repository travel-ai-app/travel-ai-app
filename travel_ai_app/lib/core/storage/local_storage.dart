import 'package:shared_preferences/shared_preferences.dart';   // Πακέτο για local αποθήκευση key-value

/// Απλή υπηρεσία για αποθήκευση/ανάγνωση string τιμών από τη συσκευή.
/// Την χρησιμοποιούμε σαν "χαμηλό επίπεδο" πάνω στο οποίο θα χτίσουμε
/// αποθήκευση trips / expenses / activities σε JSON.
class LocalStorage {
  // Κλειδιά για τα data μας (versioned για μελλοντικά migrations).
  static const String tripsKey = 'trips_v1';                   // Όλα τα trips
  static const String expensesKey = 'expenses_v1';             // Όλα τα expenses
  static const String activitiesKey = 'activities_v1';         // Όλα τα activities

  // Singleton pattern – ένα κοινό instance σε όλο το app.
  LocalStorage._internal();                                   // Ιδιωτικός constructor
  static final LocalStorage instance = LocalStorage._internal(); // Σταθερό instance

  // Εσωτερικό helper για να πάρουμε SharedPreferences.
  Future<SharedPreferences> get _prefs async {                 // Getter που επιστρέφει Future<SharedPreferences>
    return await SharedPreferences.getInstance();              // Παίρνουμε το instance
  }

  /// Διαβάζει ένα string από τα SharedPreferences με βάση το key.
  /// Επιστρέφει null αν δεν υπάρχει αποθηκευμένη τιμή.
  Future<String?> getItem(String key) async {                  // Ανάγνωση τιμής
    final prefs = await _prefs;                                // Περιμένουμε να πάρουμε το prefs
    return prefs.getString(key);                              // Επιστρέφουμε το string (ή null)
  }

  /// Αποθηκεύει ένα string value στο συγκεκριμένο key.
  Future<void> setItem(String key, String value) async {       // Αποθήκευση τιμής
    final prefs = await _prefs;                                // Παίρνουμε prefs
    await prefs.setString(key, value);                         // Γράφουμε το string
  }

  /// Διαγράφει εντελώς την αποθηκευμένη τιμή για το συγκεκριμένο key.
  Future<void> removeItem(String key) async {                  // Διαγραφή τιμής
    final prefs = await _prefs;                                // Παίρνουμε prefs
    await prefs.remove(key);                                   // Διαγράφουμε το key
  }
}
