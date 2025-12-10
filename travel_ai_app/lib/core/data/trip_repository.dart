import '../../models/trip.dart'; // Μοντέλο ταξιδιού
import '../../models/trip_day.dart'; // Μοντέλο ημέρας ταξιδιού (itinerary day)
import '../../models/activity.dart'; // Μοντέλο δραστηριότητας

/// Συμβόλαιο για πρόσβαση σε δεδομένα ταξιδιού / itinerary / activities.
abstract class TripRepository {
  /// Επιστρέφει το ενεργό ταξίδι (ή null αν δεν υπάρχει).
  Future<Trip?> getActiveTrip();

  /// Παρακολουθεί το ενεργό ταξίδι σε πραγματικό χρόνο.
  /// Προς το παρόν το fake repo θα στέλνει ένα σταθερό demo trip.
  Stream<Trip?> watchActiveTrip();

  /// Επιστρέφει τις μέρες του itinerary για ένα trip.
  Future<List<TripDay>> getItineraryDays(String tripId);

  /// Επιστρέφει όλες τις δραστηριότητες για αυτό το trip.
  Future<List<Activity>> getActivitiesForTrip(String tripId);

  /// Επιστρέφει τις δραστηριότητες για συγκεκριμένη ημερομηνία.
  Future<List<Activity>> getActivitiesForDay(String tripId, DateTime date);
}
