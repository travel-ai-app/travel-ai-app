import 'package:flutter/material.dart';

import '../../core/models/trip.dart';                          // Μοντέλο Trip
import '../../core/data/in_memory_trip_repository.dart';       // In-memory Trip repo
import '../../core/data/in_memory_expense_repository.dart';    // In-memory Expense repo
import '../../core/data/in_memory_activity_repository.dart';   // In-memory Activity repo

import 'create_trip_screen.dart';                              // Οθόνη δημιουργίας trip
import 'trip_overview_screen.dart';                            // Οθόνη overview trip

/// Οθόνη με όλα τα ταξίδια (My Trips)
class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final InMemoryTripRepository _tripRepo = InMemoryTripRepository();

  List<Trip> _trips = <Trip>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      // 1️⃣ Πρώτα φορτώνουμε από το local storage (SharedPreferences)
      await _tripRepo.loadFromStorage();                    // Διαβάζει JSON και γεμίζει _trips

      // 2️⃣ Μετά παίρνουμε τη λίστα από τη μνήμη
      final trips = _tripRepo.getTrips();                   // Παίρνουμε όλα τα trips

      setState(() {
        _trips = trips;                                     // Αποθηκεύουμε στη state
        _loading = false;                                   // Σταματάμε το loading
      });
    } catch (e) {
      setState(() {
        _trips = <Trip>[];                                  // Αν κάτι πάει στραβά → κενή λίστα
        _loading = false;                                   // Σταματάμε το loading
      });
    }
  }

  Future<void> _onCreateTripPressed() async {
    // Ανοίγουμε την CreateTripScreen και περιμένουμε να μας επιστρέψει ένα Trip
    final Trip? newTrip = await Navigator.of(context).push<Trip>(
      MaterialPageRoute(
        builder: (_) => const CreateTripScreen(),
      ),
    );

    // Αν γύρισε κανονικό trip, το αποθηκεύουμε στο in-memory repo
    if (newTrip != null) {
      final existing = InMemoryTripRepository().getTripById(newTrip.id);
      if (existing == null) {
        await InMemoryTripRepository().addTrip(newTrip);
      }
    }

    // Και μετά ανανεώνουμε τη λίστα
    await _loadTrips();
  }

  void _openTrip(Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripOverviewScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _trips.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No trips yet.\nTap the + button to create your first trip.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _trips.length,
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      return _TripListTile(
                        trip: trip,
                        onTap: () => _openTrip(trip),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateTripPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Εσωτερικό widget για ένα trip στη λίστα,
/// με mini σύνοψη (μέρες / activities / total spent).
class _TripListTile extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _TripListTile({
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = trip.startDate;
    final end = trip.endDate;
    final String currency = trip.currencyCode;

    // Ημερομηνίες ταξιδιού
    final String dateRangeText =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}'
        ' - '
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';

    // Συνολικές ημέρες από το getter totalDays
    final int dayCount = trip.totalDays;

    // Πρώτο γράμμα προορισμού για το avatar
    final String initial = trip.destination.isNotEmpty
        ? trip.destination.characters.first.toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 22,
              child: Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              trip.title.isNotEmpty ? trip.title : trip.destination,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  dateRangeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                // Mini summary (days / activities / total spent)
                _TripMiniSummaryRow(
                  trip: trip,
                  dayCount: dayCount,
                  currency: currency,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}


/// Δεδομένα σύνοψης για ένα trip.
class _TripSummary {
  final double totalExpenses;      // Σύνολο εξόδων
  final int activityCount;         // Πλήθος activities
  final int dayCount;              // Πλήθος ημερών
  final double? budget;            // Budget ταξιδιού (αν υπάρχει)
  final double? budgetPercent;     // % του budget που έχει ξοδευτεί

  const _TripSummary({
    required this.totalExpenses,
    required this.activityCount,
    required this.dayCount,
    this.budget,
    this.budgetPercent,
  });
}


/// FutureBuilder που φορτώνει mini σύνοψη για κάθε trip.
class _TripMiniSummaryRow extends StatelessWidget {
  final Trip trip;
  final int dayCount;
  final String currency;

  const _TripMiniSummaryRow({
    required this.trip,
    required this.dayCount,
    required this.currency,
  });

  Future<_TripSummary> _loadSummary() async {
    final expenseRepo = InMemoryExpenseRepository();
    final activityRepo = InMemoryActivityRepository();

    final total = await expenseRepo.getTotalForTrip(trip);
    final activities = await activityRepo.getActivitiesForTrip(trip);

    final double? budget = trip.baseBudget;
    double? budgetPercent;

    if (budget != null && budget > 0) {
      final ratio = total / budget;
      budgetPercent = (ratio * 100).clamp(0.0, 999.0);
    }

    return _TripSummary(
      totalExpenses: total,
      activityCount: activities.length,
      dayCount: dayCount,
      budget: budget,
      budgetPercent: budgetPercent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<_TripSummary>(
      future: _loadSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: SizedBox(
              height: 14,
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final summary = snapshot.data!;

        final String daysLabel =
            summary.dayCount > 0 ? '${summary.dayCount} days' : '- days';
        final String activitiesLabel =
            '${summary.activityCount} activities';

        final String spentLabel =
            '${summary.totalExpenses.toStringAsFixed(0)} $currency';

        String text;

        // Αν έχουμε budget, δείχνουμε Χ / Υ + %
        if (summary.budget != null && summary.budget! > 0) {
          final b = summary.budget!;
          final String budgetBase =
              '${summary.totalExpenses.toStringAsFixed(0)} / ${b.toStringAsFixed(0)} $currency';

          final String percentText = summary.budgetPercent != null
              ? ' (${summary.budgetPercent!.toStringAsFixed(0)}%)'
              : '';

          text =
              '$daysLabel · $activitiesLabel · $budgetBase$percentText';
        } else {
          // Χωρίς budget → όπως πριν
          text = '$daysLabel · $activitiesLabel · $spentLabel';
        }

        return Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        );
      },
    );
  }
}


