import 'package:travel_ai_app/core/models/trip.dart'; // Εισαγωγή του μοντέλου Trip
import 'package:travel_ai_app/core/models/trip_day.dart'; // Εισαγωγή του μοντέλου TripDay
import 'package:travel_ai_app/core/models/activity.dart'; // Εισαγωγή του μοντέλου Activity
import 'package:travel_ai_app/core/models/expense.dart'; // Εισαγωγή του μοντέλου Expense

class MockData { // Κλάση που κρατά όλα τα mock/demo δεδομένα
  MockData._(); // Ιδιωτικός constructor για να μη γίνεται new MockData()

  static final Trip demoTrip = Trip( // Demo ταξίδι για δοκιμή
    id: 'trip_thailand_001', // ID του ταξιδιού
    title: 'Thailand Escape', // Τίτλος ταξιδιού
    destination: 'Phuket, Thailand', // Προορισμός
    startDate: DateTime(2025, 11, 20), // Ημερομηνία έναρξης
    endDate: DateTime(2025, 11, 27), // Ημερομηνία λήξης
    currencyCode: 'THB', // Νόμισμα
    baseBudget: 60000, // Demo budget σε THB (π.χ. ~1500€)
  ); // Τέλος demoTrip

  static final List<TripDay> demoTripDays = <TripDay>[ // Λίστα με ημέρες ταξιδιού
    TripDay( // Μέρα 1
      id: 'day1', // ID ημέρας
      tripId: 'trip_thailand_001', // Ανήκει στο demoTrip
      date: DateTime(2025, 11, 20), // Ημερομηνία
      notes: 'Άφιξη στο Phuket, check-in στο ξενοδοχείο', // Σημείωση
    ), // Τέλος day1
    TripDay( // Μέρα 2
      id: 'day2', // ID ημέρας
      tripId: 'trip_thailand_001', // Ανήκει στο demoTrip
      date: DateTime(2025, 11, 21), // Ημερομηνία
      notes: 'Boat tour στα νησιά + snorkeling', // Σημείωση
    ), // Τέλος day2
  ]; // Τέλος demoTripDays λίστας

  static final List<Activity> demoActivities = <Activity>[ // Λίστα demo δραστηριοτήτων
    Activity( // Δραστηριότητα 1
      id: 'act_boat_tour', // ID δραστηριότητας
      tripId: 'trip_thailand_001', // Σχετίζεται με demoTrip
      dayId: 'day2', // Ανήκει στη μέρα 2
      title: 'Boat tour to Phi Phi Islands', // Τίτλος δραστηριότητας
      description: 'Ολοήμερη εκδρομή με βάρκα, snorkeling και παραλίες', // Περιγραφή
      type: 'activity', // Τύπος δραστηριότητας
      locationName: 'Phi Phi Islands', // Τοποθεσία
      estimatedCost: 2500, // Εκτιμώμενο κόστος σε THB
      currencyCode: 'THB', // Νόμισμα
      rating: 4.7, // Demo rating
      reviewCount: 1200, // Demo αριθμός reviews
      bookingUrl: 'https://example.com/boat-tour', // Demo link booking
    ), // Τέλος δραστηριότητας
    Activity( // Δραστηριότητα 2
      id: 'act_patong_night', // ID δραστηριότητας
      tripId: 'trip_thailand_001', // Ανήκει στο ίδιο trip
      dayId: 'day1', // Ανήκει στη μέρα 1
      title: 'Night walk at Patong', // Τίτλος
      description: 'Βόλτα στην Bangla Road, street food και bars', // Περιγραφή
      type: 'nightlife', // Τύπος
      locationName: 'Patong', // Τοποθεσία
      estimatedCost: 1500, // Εκτιμώμενο κόστος
      currencyCode: 'THB', // Νόμισμα
      rating: 4.3, // Demo rating
      reviewCount: 800, // Demo reviews
    ), // Τέλος δραστηριότητας
  ]; // Τέλος λίστας demoActivities

  static final List<Expense> demoExpenses = <Expense>[ // Λίστα demo εξόδων
    Expense( // Έξοδο 1
      id: 'exp_hotel_01', // ID εξόδου
      tripId: 'trip_thailand_001', // Σχετίζεται με demoTrip
      dateTime: DateTime(2025, 11, 20, 15, 30), // Ημερομηνία/ώρα
      amount: 12000, // Ποσό σε THB (π.χ. ξενοδοχείο)
      currencyCode: 'THB', // Νόμισμα
      category: 'Hotel', // Κατηγορία
      paymentMethod: 'Card', // Μέθοδος πληρωμής
      note: '3 nights sea view room', // Σημείωση
    ), // Τέλος εξόδου
    Expense( // Έξοδο 2
      id: 'exp_food_01', // ID εξόδου
      tripId: 'trip_thailand_001', // Σχετίζεται με demoTrip
      dateTime: DateTime(2025, 11, 20, 20, 15), // Ημερομηνία/ώρα
      amount: 600, // Ποσό (φαγητό)
      currencyCode: 'THB', // Νόμισμα
      category: 'Food', // Κατηγορία
      paymentMethod: 'Cash', // Πληρωμή με μετρητά
      note: 'Street food & smoothies', // Σημείωση
    ), // Τέλος εξόδου
    Expense( // Έξοδο 3
      id: 'exp_tour_01', // ID εξόδου
      tripId: 'trip_thailand_001', // Σχετίζεται με demoTrip
      dateTime: DateTime(2025, 11, 21, 8, 0), // Ημερομηνία/ώρα
      amount: 2500, // Ποσό (boat tour)
      currencyCode: 'THB', // Νόμισμα
      category: 'Activity', // Κατηγορία
      paymentMethod: 'Card', // Πληρωμή με κάρτα
      note: 'Boat tour to Phi Phi', // Σημείωση
    ), // Τέλος εξόδου
  ]; // Τέλος λίστας demoExpenses

  static double get totalDemoExpensesThb { // Υπολογισμός συνολικού ποσού demo εξόδων
    return demoExpenses // Παίρνουμε τη λίστα demoExpenses
        .map((Expense e) => e.amount) // Κρατάμε μόνο τα amounts
        .fold(0.0, (double sum, double value) => sum + value); // Αθροίζουμε όλα τα ποσά
  } // Τέλος getter totalDemoExpensesThb
} // Τέλος κλάσης MockData
