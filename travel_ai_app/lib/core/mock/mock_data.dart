/// Mock δεδομένα για demo οθόνες και fake repositories.
/// ΠΡΟΣΩΡΙΝΗ εκδοχή για να σταματήσουν τα errors.
/// Μπορούμε αργότερα να τα γεμίσουμε με πραγματικά demo data.

import '../models/trip.dart';
import '../models/trip_day.dart';
import '../models/activity.dart';
import '../models/expense.dart';
import '../models/day_part.dart'; // Για το DayPart.morning / afternoon κτλ


class MockData {
  /// Demo ταξίδι (προς το παρόν πολύ απλό).
static Trip get demoTrip {
  return Trip(
    id: 'trip_thailand_001',
    title: 'Thailand Demo Trip',
    destination: 'Thailand',
    startDate: DateTime(2025, 1, 10),
    endDate: DateTime(2025, 1, 20),
    currencyCode: 'THB', // Προσθέσαμε αυτό
  );
}







  /// Demo λίστα ημερών ταξιδιού.
  static List<TripDay> get demoTripDays {
    return const []; // Μπορούμε να βάλουμε αργότερα πραγματικές μέρες.
  }

  /// Demo λίστα δραστηριοτήτων (συνδεδεμένες με το demoTrip).
  static List<Activity> get demoActivities {
    return [
      Activity(
        id: 'act_001',
        title: 'Visit Big Buddha',
        description: 'Morning visit to Big Buddha temple.',
        date: DateTime(2025, 1, 11),
        estimatedCost: 0,
        currencyCode: 'THB',
        category: 'Sightseeing',
        tripId: 'trip_thailand_001',
        dayId: 'day_1',
        dayPart: DayPart.morning,
      ),
      Activity(
        id: 'act_002',
        title: 'Beach time',
        description: 'Relax at Patong Beach.',
        date: DateTime(2025, 1, 11),
        estimatedCost: 500,
        currencyCode: 'THB',
        category: 'Beach',
        tripId: 'trip_thailand_001',
        dayId: 'day_1',
        dayPart: DayPart.afternoon,
      ),
    ];
  }

  /// Demo έξοδα για το demo trip.
  static List<Expense> get demoExpenses {
    return <Expense>[];
  }

  /// Σύνολο demo εξόδων σε THB (μπορείς να το αλλάξεις ελεύθερα).
  static double get totalDemoExpensesThb {
    return demoExpenses.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );
  }
}
