import 'package:flutter/material.dart'; // ui //

import '../../core/models/trip.dart'; // Trip model //
import '../../core/data/in_memory_trip_repository.dart'; // Trip repo //
import '../../core/data/in_memory_expense_repository.dart'; // Expense repo //
import '../../core/data/in_memory_activity_repository.dart'; // Activity repo //

import 'create_trip_screen.dart'; // Create/Edit screen //
import 'trip_overview_screen.dart'; // Trip overview //
import 'package:travel_ai_app/core/constants/app_limits.dart'; // limits //
import 'package:travel_ai_app/presentation/upgrade_dialog.dart'; // upgrade dialog //
import 'package:travel_ai_app/core/monetization/monetization_gate.dart'; // gate //
import 'package:travel_ai_app/core/monetization/monetization_state.dart'; // state //


/// Οθόνη με όλα τα ταξίδια (My Trips)
class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final InMemoryTripRepository _tripRepo = InMemoryTripRepository(); // repo //

  List<Trip> _trips = <Trip>[]; // trips //
  bool _loading = true; // loading //

  @override
  void initState() {
    super.initState(); // init //
    _loadTrips(); // load //
  }

  Future<void> _loadTrips() async {
    try {
      await _tripRepo.loadFromStorage(); // load from prefs //
      final trips = _tripRepo.getTrips(); // get from memory //

      if (!mounted) return; // safety //
      setState(() {
        _trips = trips; // set trips //
        _loading = false; // stop loading //
      });
    } catch (e) {
      if (!mounted) return; // safety //
      setState(() {
        _trips = <Trip>[]; // empty //
        _loading = false; // stop loading //
      });
    }
  }

  Future<void> _onCreateTripPressed() async {
    final Trip? newTrip = await Navigator.of(context).push<Trip>( // open create //
      MaterialPageRoute(
        builder: (_) => const CreateTripScreen(), // create //
      ),
    );

    if (newTrip != null) {
      final existing = _tripRepo.getTripById(newTrip.id); // check exists //
      if (existing == null) {
        await _tripRepo.addTrip(newTrip); // add //
      }
    }

    await _loadTrips(); // refresh //
  }

  Future<void> _onEditTripPressed(Trip trip) async {
    final Trip? updatedTrip = await Navigator.of(context).push<Trip>( // open edit //
      MaterialPageRoute(
        builder: (_) => CreateTripScreen(existingTrip: trip), // prefill //
      ),
    );

    if (updatedTrip != null) {
      // NOTE: updateTrip must exist in repo (see below) //
      await _tripRepo.updateTrip(updatedTrip); // update + persist //
      await _loadTrips(); // refresh //
      if (!context.mounted) return; // safety //
      ScaffoldMessenger.of(context).showSnackBar( // feedback //
        const SnackBar(content: Text('Trip updated')), // msg //
      ); // snackbar //
    }
  }

  void _openTrip(Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripOverviewScreen(trip: trip), // overview //
      ),
    );
  }

  Future<bool> _confirmDeleteTrip(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trip'),
        content: const Text(
          'This will permanently delete this trip and all its data.\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _deleteTripAndRefresh(Trip trip) async {
    await _tripRepo.deleteTrip(trip.id); // delete + persist //
    await _loadTrips(); // refresh //
    if (!context.mounted) return; // safety //
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip deleted')),
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

                      return Dismissible(
                        key: ValueKey(trip.id),
                        direction: DismissDirection.horizontal, // ✅ both //

                        // ✅ Swipe δεξιά (Edit)
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.blueGrey,
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),

                        // ✅ Swipe αριστερά (Delete)
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        confirmDismiss: (direction) async {
                          // ✅ right swipe -> edit (NO dismiss)
                          if (direction == DismissDirection.startToEnd) {
                            await _onEditTripPressed(trip); // edit flow //
                            return false; // do not remove //
                          }

                          // ✅ left swipe -> delete (confirm)
                          if (direction == DismissDirection.endToStart) {
                            return await _confirmDeleteTrip(context); // confirm //
                          }

                          return false;
                        },

                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            await _deleteTripAndRefresh(trip); // delete //
                          }
                        },

                        child: _TripListTile(
                          trip: trip,
                          onTap: () => _openTrip(trip),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repo = InMemoryTripRepository(); // repo //
          final trips = await repo.getTrips(); // existing //

          // 🔒 v1 LIMIT: 1 active trip
final gate = MonetizationGate.canCreateTrip( // gate check //
  state: AppLimits.isPro // current tier source //
      ? MonetizationState.premium // premium //
      : MonetizationState.free, // free //
  activeTripsCount: trips.length, // active trips //
); // end gate //

if (gate != GateResult.allowed) { // blocked //
  if (!context.mounted) return; // safety //
  await showUpgradeDialog( // existing dialog //
    context, // ctx //
    reason: UpgradeReason.tripLimit, // keep same reason //
  ); // end dialog //
  return; // stop //
} // end blocked //


          await _onCreateTripPressed(); // create //
        },
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

    final String dateRangeText =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}'
        ' - '
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';

    final int dayCount = trip.totalDays;

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
  final double totalExpenses;
  final int activityCount;
  final int dayCount;
  final double? budget;
  final double? budgetPercent;

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
        final String activitiesLabel = '${summary.activityCount} activities';
        final String spentLabel =
            '${summary.totalExpenses.toStringAsFixed(0)} $currency';

        String text;

        if (summary.budget != null && summary.budget! > 0) {
          final b = summary.budget!;
          final String budgetBase =
              '${summary.totalExpenses.toStringAsFixed(0)} / ${b.toStringAsFixed(0)} $currency';

          final String percentText = summary.budgetPercent != null
              ? ' (${summary.budgetPercent!.toStringAsFixed(0)}%)'
              : '';

          text = '$daysLabel · $activitiesLabel · $budgetBase$percentText';
        } else {
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
