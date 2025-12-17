import 'dart:async';                             // Για StreamController
import 'dart:convert';                           // Για jsonEncode / jsonDecode

import '../models/trip.dart';                    // Μοντέλο Trip
import '../models/trip_day.dart';                // Μοντέλο TripDay (προς χρήση αργότερα)
import '../models/activity.dart';                // Μοντέλο Activity (προς χρήση αργότερα)
import 'trip_repository.dart';                   // Το abstract TripRepository σου
import '../storage/local_storage.dart';          // LocalStorage service (SharedPreferences)

/// In-memory υλοποίηση του TripRepository.                       // Περιγραφή κλάσης
/// Κρατάει trips στη μνήμη ΚΑΙ τα αποθηκεύει/φορτώνει            // In-memory + persistence
/// από local storage (SharedPreferences) σε JSON.                 // Χρήση JSON για trips
///
/// ΣΤΟΧΟΣ:
/// - Να χρησιμοποιείται από τα screens (MyTrips, TripOverview, κτλ) // Χρήση από UI
/// - Αργότερα μπορούμε να τον αντικαταστήσουμε με Firestore κ.λπ.  // Επέκταση σε cloud
class InMemoryTripRepository implements TripRepository {           // Δήλωση κλάσης
  // Singleton pattern – ένα κοινό instance σε όλο το app         // Singleton για κοινά δεδομένα
  static final InMemoryTripRepository _instance =
      InMemoryTripRepository._internal();                          // Ιδιωτικός constructor

  factory InMemoryTripRepository() => _instance;                   // Δημόσιο factory

  InMemoryTripRepository._internal();                              // Ιδιωτικός constructor

  final List<Trip> _trips = <Trip>[];                              // Όλα τα trips στη μνήμη
  Trip? _activeTrip;                                               // Τρέχον (ενεργό) ταξίδι

  final StreamController<Trip?> _activeTripController =
      StreamController<Trip?>.broadcast();                         // Stream για αλλαγές activeTrip

  bool _loadedFromStorage = false;                                 // Flag αν φορτώσαμε από storage

  // =======================
  //  TripRepository methods
  // =======================

  @override
  Future<Trip?> getActiveTrip() async {                            // Επιστροφή ενεργού trip
    return _activeTrip;                                            // Επιστροφή activeTrip
  }

  @override
  Stream<Trip?> watchActiveTrip() {                                // Stream για activeTrip
    return _activeTripController.stream;                           // Επιστροφή stream
  }

  @override
  Future<List<TripDay>> getItineraryDays(String tripId) async {    // Placeholder για TripDay
    // Προς το παρόν δεν έχουμε πραγματικό TripDay μοντέλο/δεδομένα. // TODO αργότερα
    return <TripDay>[];                                            // Επιστροφή κενής λίστας
  }

  @override
  Future<List<Activity>> getActivitiesForTrip(String tripId) async { // Placeholder για activities
    // Placeholder: δεν έχουμε ακόμα αποθήκευση δραστηριοτήτων.    // TODO αργότερα
    return <Activity>[];                                           // Κενή λίστα
  }

  @override
  Future<List<Activity>> getActivitiesForDay(
    String tripId,                                                 // ID ταξιδιού
    DateTime date,                                                 // Ημερομηνία
  ) async {
    // Placeholder: θα φιλτράρουμε αργότερα με βάση ημερομηνία/dayPart. // TODO
    return <Activity>[];                                           // Κενή λίστα
  }

  // =======================
  //  Επιπλέον helper methods
  //  (για χρήση από UI & persistence)
  // =======================

  /// Φορτώνει τα trips από το local storage ΜΟΝΟ την πρώτη φορά.  // Lazy load από storage
Future<void> loadFromStorage() async {                           // Δημόσια μέθοδος φόρτωσης
  if (_loadedFromStorage) return;                                // Αν ήδη φορτώσαμε, βγαίνουμε
  _loadedFromStorage = true;                                     // Σημειώνουμε ότι φορτώσαμε

  final storage = LocalStorage.instance;                         // Παίρνουμε LocalStorage
  final raw = await storage.getItem(LocalStorage.tripsKey);      // Διαβάζουμε raw JSON string

  if (raw == null || raw.isEmpty) {                              // Αν δεν υπάρχει τίποτα
    return;                                                      // Δεν κάνουμε κάτι
  }

  try {
    final decoded = jsonDecode(raw);                             // Κάνουμε decode JSON
    if (decoded is List) {                                       // Περιμένουμε λίστα
      final List<Trip> loadedTrips = <Trip>[];                   // Λίστα φορτωμένων trips

      for (final item in decoded) {                              // Loop σε κάθε στοιχείο
        if (item is Map<String, dynamic>) {                      // Αν είναι ήδη Map<String,dynamic>
          loadedTrips.add(Trip.fromJson(item));                  // Χρησιμοποιούμε Trip.fromJson
        } else if (item is Map) {                                // Generic Map (web / cast)
          final map = item.map(                                  // Μετατροπή σε Map<String,dynamic>
            (key, value) => MapEntry(key.toString(), value),
          );
          loadedTrips.add(Trip.fromJson(map));                   // Trip.fromJson
        }
      }

      _trips
        ..clear()                                                // Καθαρίζουμε την τρέχουσα λίστα
        ..addAll(loadedTrips);                                   // Προσθέτουμε τα φορτωμένα

      _activeTrip = _trips.isNotEmpty ? _trips.first : null;     // Ορίζουμε activeTrip το πρώτο
      _activeTripController.add(_activeTrip);                    // Ενημερώνουμε το stream
    }
  } catch (e) {
    // Αν κάτι πάει στραβά στο JSON, το αγνοούμε για τώρα.         // TODO: logging αν θέλουμε
  }
}


  /// Αποθηκεύει ΟΛΑ τα trips σε JSON στο local storage.           // Persist όλων των trips
Future<void> _persistToStorage() async {                         // Ιδιωτική μέθοδος αποθήκευσης
  final storage = LocalStorage.instance;                         // Παίρνουμε LocalStorage

  final List<Map<String, dynamic>> data = _trips                 // Μετατροπή trips -> List<Map>
      .map((trip) => trip.toJson())                              // Χρήση Trip.toJson()
      .toList();

  final raw = jsonEncode(data);                                  // Encode σε JSON string
  await storage.setItem(LocalStorage.tripsKey, raw);             // Αποθήκευση στο storage
}


  /// Επιστρέφει ΟΛΑ τα trips που έχουν δημιουργηθεί μέχρι τώρα.  // Getter για trips
  /// (προς το παρόν μόνο in-memory, αλλά μετά το loadFromStorage) // Μετά το load έχει και saved
  List<Trip> getTrips() {                                          // Δημόσια μέθοδος
    return List<Trip>.unmodifiable(_trips);                        // Επιστρέφουμε unmodifiable λίστα
  }

  /// Προσθέτει ένα νέο trip στη μνήμη ΚΑΙ το αποθηκεύει.          // Προσθήκη + persistence
  /// Αν δεν υπάρχει ενεργό trip, το κάνει active.                 // Auto active πρώτο trip
  Future<void> addTrip(Trip trip) async {                          // Προσθήκη trip
    _trips.add(trip);                                              // Προσθήκη στη λίστα
    // Αν δεν έχουμε activeTrip, ορίζουμε αυτόματα το πρώτο.       // Έλεγχος activeTrip
    _activeTrip ??= trip;                                          // Αν είναι null, θέτουμε το trip
    _activeTripController.add(_activeTrip);                        // Ενημερώνουμε stream
    await _persistToStorage();                                     // Αποθήκευση όλων των trips
  }

  /// Θέτει συγκεκριμένο trip ως ενεργό και αποθηκεύει την αλλαγή. // Ορισμός activeTrip
  Future<void> setActiveTrip(Trip trip) async {                    // Setter activeTrip
    _activeTrip = trip;                                            // Θέτουμε activeTrip
    _activeTripController.add(_activeTrip);                        // Ενημερώνουμε stream
    await _persistToStorage();                                     // Αποθήκευση αλλαγής
  }

  /// Διαγράφει ένα trip από τη λίστα (in-memory + storage).       // Διαγραφή trip
  Future<void> deleteTrip(String tripId) async {                   // Διαγραφή με βάση id
    _trips.removeWhere((t) => t.id == tripId);                     // Αφαίρεση από λίστα
    if (_activeTrip?.id == tripId) {                               // Αν ήταν active
      _activeTrip = _trips.isNotEmpty ? _trips.first : null;       // Ορίζουμε νέο active ή null
      _activeTripController.add(_activeTrip);                      // Ενημέρωση stream
    }
    await _persistToStorage();                                     // Αποθήκευση μετά τη διαγραφή
  }

  /// Επιστρέφει ένα trip βάση id (ή null αν δεν βρεθεί).          // Αναζήτηση trip
  Trip? getTripById(String tripId) {                               // Μέθοδος get-by-id
    try {
      return _trips.firstWhere((t) => t.id == tripId);             // Εύρεση πρώτου που ταιριάζει
    } catch (_) {
      return null;                                                 // Αν δεν βρεθεί, null
    }
  }

  /// Καθαρίζει όλα τα δεδομένα (χρήσιμο για debug/reset).         // Reset όλων
  Future<void> clearAll() async {                                  // Καθαρισμός
    _trips.clear();                                                // Καθαρισμός λίστας
    _activeTrip = null;                                            // Μηδενισμός activeTrip
    _activeTripController.add(_activeTrip);                        // Ενημέρωση stream
    await LocalStorage.instance.removeItem(LocalStorage.tripsKey); // Διαγραφή από storage
  }

  /// Καλύτερα να κλείσουμε το stream όταν τερματίζει η εφαρμογή.  // Cleanup
  void dispose() {                                                 // Μέθοδος dispose
    _activeTripController.close();                                 // Κλείσιμο stream controller
  }

  // =======================
  //  JSON helpers για Trip
  // =======================



}
