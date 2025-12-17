import '../models/activity.dart';  // Μοντέλο Activity
import '../models/trip.dart';      // Μοντέλο Trip
import '../models/day_part.dart';  // Πρωί / Απόγευμα / Βράδυ

/// Συμβόλαιο για πρόσβαση σε δραστηριότητες ενός trip.
abstract class ActivityRepository {
  /// Όλες οι δραστηριότητες ενός trip.
  Future<List<Activity>> getActivitiesForTrip(Trip trip);

  /// Δραστηριότητες για συγκεκριμένη ημέρα (ημερομηνία).
  Future<List<Activity>> getActivitiesForDay(Trip trip, DateTime date);

  /// Δραστηριότητες για συγκεκριμένη ημέρα + day part (Morning / Afternoon / Evening).
  Future<List<Activity>> getActivitiesForDayPart(
    Trip trip,
    DateTime date,
    DayPart dayPart,
  );

  /// Προσθήκη νέας δραστηριότητας σε trip.
  Future<void> addActivity({
    required Trip trip,
    required Activity activity,
  });

  /// Διαγραφή δραστηριότητας με βάση το id.
  Future<void> deleteActivity(String activityId);
}
