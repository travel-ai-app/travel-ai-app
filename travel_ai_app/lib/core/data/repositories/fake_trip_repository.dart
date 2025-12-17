import 'dart:async';

// import '../../mock/mock_data.dart'; // Demo δεδομένα (trip, days, activities)
import '../../models/trip.dart'; // Trip model
import '../../models/trip_day.dart'; // TripDay model
import '../../models/activity.dart'; // Activity model
import 'package:travel_ai_app/core/data/trip_repository.dart'; // Το συμβόλαιο

/// Fake υλοποίηση του TripRepository που διαβάζει από MockData.
class FakeTripRepository implements TripRepository {
  FakeTripRepository();

@override
Future<Trip?> getActiveTrip() async {
  return null; // δεν επιστρέφουμε demo trip
}

@override
Stream<Trip?> watchActiveTrip() async* {
  yield null; // δεν εκπέμπουμε demo trip
}
@override
Future<List<TripDay>> getItineraryDays(String tripId) async {
  return <TripDay>[]; // κανένα demo day
}


@override
Future<List<Activity>> getActivitiesForTrip(String tripId) async {
  return <Activity>[]; // κανένα demo activity
}


@override
Future<List<Activity>> getActivitiesForDay(
  String tripId,
  DateTime date,
) async {
  return <Activity>[]; // κανένα demo activity
}


  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}
