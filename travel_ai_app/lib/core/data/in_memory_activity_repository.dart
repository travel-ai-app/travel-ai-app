import 'dart:convert';                                      // Για jsonEncode / jsonDecode

import '../models/activity.dart';                           // Μοντέλο Activity
import '../models/trip.dart';                               // Μοντέλο Trip
import '../models/day_part.dart';                           // Πρωί / Απόγευμα / Βράδυ
import '../storage/local_storage.dart';                     // LocalStorage (SharedPreferences)
import 'activity_repository.dart';                          // Το abstract ActivityRepository

/// In-memory υλοποίηση του ActivityRepository.
/// Κρατάει όλες τις δραστηριότητες σε λίστα στη μνήμη
/// ΚΑΙ τις αποθηκεύει / φορτώνει από local storage σε JSON.
class InMemoryActivityRepository implements ActivityRepository {
  // Singleton instance – ίδιο repo σε όλο το app
  static final InMemoryActivityRepository _instance =
      InMemoryActivityRepository._internal();

  factory InMemoryActivityRepository() => _instance;

  InMemoryActivityRepository._internal();

  // Όλες οι δραστηριότητες στη μνήμη
  final List<Activity> _activities = <Activity>[];

  // Flag: αν έχουμε ήδη φορτώσει από storage
  bool _loadedFromStorage = false;

  // Key που θα χρησιμοποιούμε στο LocalStorage αποκλειστικά για activities
  static const String _storageKey = 'activities_v1';

  /// Προαιρετικό public helper αν θες κάποτε να κάνεις ρητή φόρτωση.
  Future<void> loadFromStorage() async {
    await _ensureLoaded();
  }

  /// Εσωτερικός helper:
  /// Φορτώνει όλες τις δραστηριότητες από LocalStorage ΜΟΝΟ την πρώτη φορά.
  Future<void> _ensureLoaded() async {
    if (_loadedFromStorage) {
      return;
    }

    _loadedFromStorage = true;

    final storage = LocalStorage.instance;
    final raw = await storage.getItem(_storageKey);         // Διαβάζουμε το JSON string

    if (raw == null || raw.isEmpty) {
      print('[ActivityRepo] No stored activities found');
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _activities.clear();

        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _activities.add(Activity.fromJson(item));
          } else if (item is Map) {
            final map = item.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            _activities.add(Activity.fromJson(map));
          }
        }

        print('[ActivityRepo] Loaded ${_activities.length} activities from storage');
      } else {
        print('[ActivityRepo] Decoded JSON is not a List');
      }
    } catch (e) {
      print('[ActivityRepo] Error loading activities: $e');
      // Αν το JSON είναι χαλασμένο, προς το παρόν απλώς το αγνοούμε.
    }
  }

  /// Αποθηκεύει ΟΛΕΣ τις δραστηριότητες στο LocalStorage ως JSON.
  Future<void> _persistToStorage() async {
    final storage = LocalStorage.instance;

    final List<Map<String, dynamic>> data =
        _activities.map((a) => a.toJson()).toList();

    final raw = jsonEncode(data);
    await storage.setItem(_storageKey, raw);

    print('[ActivityRepo] Persisted ${_activities.length} activities to storage');
  }

  // ===================================================
  //  Υλοποίηση των abstract μεθόδων του ActivityRepository
  // ===================================================

  /// Όλες οι δραστηριότητες ενός trip.
  @override
  Future<List<Activity>> getActivitiesForTrip(Trip trip) async {
    await _ensureLoaded();

    final result = _activities
        .where((a) => a.tripId == trip.id)
        .toList();

    print('[ActivityRepo] getActivitiesForTrip(${trip.id}) -> ${result.length} items');

    return result;
  }

  /// Δραστηριότητες για συγκεκριμένη ημερομηνία (ανεξάρτητα από dayPart).
  @override
  Future<List<Activity>> getActivitiesForDay(
    Trip trip,
    DateTime date,
  ) async {
    await _ensureLoaded();

    final result = _activities.where((a) {
      if (a.tripId != trip.id) return false;
      if (a.date == null) return false;

      return _isSameDate(a.date!, date);
    }).toList();

    print('[ActivityRepo] getActivitiesForDay(${trip.id}, $date) -> ${result.length} items');

    return result;
  }

  /// Δραστηριότητες για συγκεκριμένη ημερομηνία + dayPart.
  @override
  Future<List<Activity>> getActivitiesForDayPart(
    Trip trip,
    DateTime date,
    DayPart dayPart,
  ) async {
    await _ensureLoaded();

    final result = _activities.where((a) {
      if (a.tripId != trip.id) return false;
      if (a.date == null) return false;
      if (!_isSameDate(a.date!, date)) return false;
      return a.dayPart == dayPart;
    }).toList();

    print(
      '[ActivityRepo] getActivitiesForDayPart(${trip.id}, $date, $dayPart) -> ${result.length} items',
    );

    return result;
  }

  /// Προσθήκη νέας δραστηριότητας σε trip.
  @override
  Future<void> addActivity({
    required Trip trip,
    required Activity activity,
  }) async {
    await _ensureLoaded();

    // Σιγουρευόμαστε ότι το activity έχει σωστό tripId
    final Activity normalized = (activity.tripId == trip.id)
        ? activity
        : activity.copyWith(tripId: trip.id);

    _activities.add(normalized);

    await _persistToStorage();
  }

  /// Διαγραφή δραστηριότητας με βάση το id.
  @override
  Future<void> deleteActivity(String activityId) async {
    await _ensureLoaded();

    _activities.removeWhere((a) => a.id == activityId);

    await _persistToStorage();
  }

/// Update activity (replace by id)
Future<void> updateActivity(Activity activity) async {
  await _ensureLoaded();
  final idx = _activities.indexWhere((a) => a.id == activity.id);
  if (idx == -1) {
    _activities.add(activity);
  } else {
    _activities[idx] = activity;
  }
  await _persistToStorage();
}



  /// Helper για σύγκριση ημερομηνιών μόνο ως προς year/month/day.
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  /// Προαιρετικό helper αν θες να καθαρίσεις όλα τα activities (debug/reset).
  Future<void> clearAll() async {
    _activities.clear();
    await LocalStorage.instance.removeItem(_storageKey);
    _loadedFromStorage = false;
    print('[ActivityRepo] Cleared all activities');
  }


  /// ✅ Seed demo activities ΜΟΝΟ 1 φορά (αν δεν υπάρχει ήδη storage).
  /// Δεν ξαναγράφει ποτέ αν υπάρχει έστω και κενό JSON "[]".
  Future<void> seedDemoOnce(List<Activity> seed) async { // seed once //
    final storage = LocalStorage.instance; // storage //
    final raw = await storage.getItem(_storageKey); // read //

    // Αν υπάρχει ήδη τιμή (ακόμα και "[]"), δεν ξανακάνουμε seed.
if (raw != null) {
  _loadedFromStorage = true; // 👈 ΠΟΛΥ ΣΗΜΑΝΤΙΚΟ
  return;
}


    _activities // list //
      ..clear() // clear //
      ..addAll(seed); // add seed //

    _loadedFromStorage = true; // mark loaded //
    await _persistToStorage(); // persist //
  } // end //



}
