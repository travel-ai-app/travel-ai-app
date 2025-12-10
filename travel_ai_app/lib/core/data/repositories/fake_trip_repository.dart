import 'dart:async';

import '../../mock/mock_data.dart'; // Demo δεδομένα (trip, days, activities)
import '../../models/trip.dart'; // Trip model
import '../../models/trip_day.dart'; // TripDay model
import '../../models/activity.dart'; // Activity model
import 'trip_repository.dart'; // Το συμβόλαιο

/// Fake υλοποίηση του TripRepository που διαβάζει από MockData.
class FakeTripRepository implements TripRepository {
  FakeTripRepository();

  @override
  Future<Trip?> getActiveTrip() async {
    // Προς το παρόν έχουμε μόνο ένα demo trip.
    return MockData.demoTrip;
  }

  @override
  Stream<Trip?> watchActiveTrip() async* {
    // Απλά εκπέμπουμε μια φορά το demo trip.
    yield MockData.demoTrip;
  }

  @override
  Future<List<TripDay>> getItineraryDays(String tripId) async {
    // Φιλτράρουμε τις μέρες του demo trip με βάση το tripId.
    return MockData.demoTripDays
        .where((TripDay d) => d.tripId == tripId)
        .toList();
  }

  @override
  Future<List<Activity>> getActivitiesForTrip(String tripId) async {
    // Φιλτράρουμε όλες τις δραστηριότητες που ανήκουν στο trip.
    return MockData.demoActivities
        .where((Activity a) => a.tripId == tripId)
        .toList();
  }

  @override
  Future<List<Activity>> getActivitiesForDay(
      String tripId,
      DateTime date,
      ) async {
    // Βρίσκουμε ποιες TripDay έχουν την ίδια ημερομηνία για αυτό το trip.
    final List<TripDay> daysForDate = MockData.demoTripDays.where(
          (TripDay d) =>
      d.tripId == tripId && _isSameDate(d.date, date),
    ).toList();

    if (daysForDate.isEmpty) {
      return <Activity>[];
    }

    final Set<String> dayIds =
    daysForDate.map((TripDay d) => d.id).toSet();

    // Φιλτράρουμε δραστηριότητες με βάση τα dayIds.
    return MockData.demoActivities
        .where((Activity a) => dayIds.contains(a.dayId))
        .toList();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}
