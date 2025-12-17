import 'package:flutter/material.dart';

import '../../core/models/trip.dart';                            // Μοντέλο Trip
import '../../core/models/expense.dart';                        // Μοντέλο Expense
import '../../core/data/in_memory_expense_repository.dart';     // In-memory Expense repo

import '../../core/models/activity.dart';                       // Μοντέλο Activity
import '../../core/models/day_part.dart';                       // DayPart enum
import '../../core/data/in_memory_activity_repository.dart';    // In-memory Activity repo
import 'categories_breakdown_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../expenses/add_expense_demo_screen.dart'; // ή το σωστό path στο project σου
import '../expenses/expense_details_bottom_sheet.dart';
import 'package:travel_ai_app/presentation/activity_details_bottom_sheet.dart';
/// Οθόνη επισκόπησης για ένα Trip με tabs:
/// - Overview
/// - Itinerary
/// - Expenses
class TripOverviewScreen extends StatelessWidget {
  final Trip trip;

  const TripOverviewScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(trip.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
              Tab(text: 'Itinerary', icon: Icon(Icons.map_outlined)),
              Tab(text: 'Expenses', icon: Icon(Icons.attach_money)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(trip: trip),
            _ItineraryTab(trip: trip),
            _ExpensesTab(trip: trip),
          ],
        ),
      ),
    );
  }
}

/// TAB 1 – Overview με σύνοψη (expenses + activities + days + budget + smart tip)
class _OverviewTab extends StatefulWidget {
  final Trip trip;

  const _OverviewTab({required this.trip});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}


class _OverviewTabState extends State<_OverviewTab> {
  final InMemoryExpenseRepository _expenseRepo = InMemoryExpenseRepository(); // Repo εξόδων
  final InMemoryActivityRepository _activityRepo = InMemoryActivityRepository(); // Repo activities

  bool _loading = true; // Loading state
  double _totalExpenses = 0.0; // Σύνολο εξόδων
  int _activityCount = 0; // Πλήθος activities
  Map<String, double> _totalsByCategory = <String, double>{}; // Totals ανά category
    Map<String, double> _totalsByDay = <String, double>{}; // Totals ανά ημέρα
  double _todayTotal = 0.0; // Σύνολο σήμερα
  double _yesterdayTotal = 0.0; // Σύνολο χθες


  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

Future<void> _loadSummary() async {
  if (!mounted) return;

  setState(() {
    _loading = true;
  });

  try {
    final trip = widget.trip;

    final total = await _expenseRepo.getTotalForTrip(trip);
    final activities = await _activityRepo.getActivitiesForTrip(trip);
    final totalsByCategory = await _expenseRepo.getTotalsByCategoryForTrip(trip);
    final totalsByDay = await _expenseRepo.getTotalsByDayForTrip(trip);

    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final y = now.subtract(const Duration(days: 1));
    final yesterdayKey =
        '${y.year.toString().padLeft(4, '0')}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';

    final todayTotal = totalsByDay[todayKey] ?? 0.0;
    final yesterdayTotal = totalsByDay[yesterdayKey] ?? 0.0;

    if (!mounted) return;

    setState(() {
      _totalExpenses = total;
      _activityCount = activities.length;
      _totalsByCategory = totalsByCategory;

      _totalsByDay = totalsByDay;
      _todayTotal = todayTotal;
      _yesterdayTotal = yesterdayTotal;
    });
  } catch (e) {
    // για να μην μένει για πάντα loading
    if (!mounted) return;
    setState(() {
      _totalsByCategory = <String, double>{};
      _totalsByDay = <String, double>{};
      _todayTotal = 0.0;
      _yesterdayTotal = 0.0;
    });
    debugPrint('Overview _loadSummary error: $e');
  } finally {
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }
}


  /// "Έξυπνο" τοπικό tip με βάση budget + έξοδα
  String _buildSmartTip({
    required double totalExpenses,
    required double? budget,
    required int dayCount,
  }) {
    if (budget == null || budget <= 0) {
      if (totalExpenses == 0) {
        return "Δεν έχεις καταγράψει ακόμη έξοδα. Κατέγραψε τα βασικά (φαγητό, μεταφορές, διαμονή) για να δεις τη μεγάλη εικόνα του ταξιδιού.";
      }
      return "Παρακολούθησε σε ποιες κατηγορίες ξοδεύεις πιο πολύ. Μικρές αλλαγές σε 1–2 κατηγορίες κάνουν μεγάλη διαφορά στο συνολικό κόστος.";
    }

    final ratio = totalExpenses / budget;
    final spentPercent = ratio * 100;

    if (totalExpenses == 0) {
      return "Έχεις ορίσει budget αλλά δεν έχεις ακόμη έξοδα. Κατέγραψε τις πρώτες σου κινήσεις για να δεις αν ο ρυθμός σου ταιριάζει με το πλάνο.";
    }

    if (spentPercent < 40) {
      return "Είσαι αρκετά κάτω από το budget σου. Μπορείς να απολαύσεις λίγες extra εμπειρίες χωρίς να αγχωθείς για τα χρήματα.";
    } else if (spentPercent < 75) {
      return "Βρίσκεσαι περίπου στη μέση του budget. Παρακολούθησε καθημερινά τα έξοδά σου ώστε να μην ξεφύγεις στα τελευταία days του ταξιδιού.";
    } else if (spentPercent < 100) {
      return "Έχεις ήδη ξοδέψει πάνω από το 75% του budget. Προσπάθησε τις επόμενες μέρες να επιλέγεις πιο οικονομικές δραστηριότητες και φαγητό.";
    } else {
      return "Έχεις ξεπεράσει το budget αυτού του ταξιδιού. Ίσως αξίζει να μειώσεις τα έξοδα σε προαιρετικές δραστηριότητες και να κρατήσεις μόνον ό,τι είναι must-do.";
    }
  }

  /// ✅ ΠΡΟΣΘΗΚΗ: "AI-like" insight με βάση categories
  String _buildCategoryInsightText({
    required Map<String, double> totalsByCategory,
    required double totalExpenses,
    required String currency,
  }) {
    if (totalExpenses <= 0 || totalsByCategory.isEmpty) {
      return 'Add a few expenses to unlock category insights.';
    }

    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = entries.first;
    final topPercent = (top.value / totalExpenses) * 100;

    MapEntry<String, double>? second;
    if (entries.length >= 2) {
      second = entries[1];
    }

    final savingsIf10 = top.value * 0.10;

    final String base =
        'Most of your spending is in "${top.key}" (${topPercent.toStringAsFixed(0)}%).';

    final String extra = second != null ? ' Next is "${second.key}".' : '';

    final String whatIf =
        ' If you cut "${top.key}" by 10%, you save ~${savingsIf10.toStringAsFixed(0)} $currency.';

    return base + extra + whatIf;
  }

  /// Top 3 categories (sorted by amount desc)
  List<MapEntry<String, double>> _topCategories() {
    final list = _totalsByCategory.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    if (list.length > 3) {
      return list.take(3).toList();
    }
    return list;
  }

  MapEntry<String, double>? _topSpendingDay() {
    if (_totalsByDay.isEmpty) return null;

    final entries = _totalsByDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.first;
  }

  List<FlSpot> _last7DaysSpots() {
    final now = DateTime.now();
    final List<FlSpot> spots = <FlSpot>[];

    // 6 μέρες πριν έως σήμερα (7 σημεία)
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final v = _totalsByDay[key] ?? 0.0;
      spots.add(FlSpot((6 - i).toDouble(), v));
    }

    return spots;
  }



  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final start = trip.startDate;
    final end = trip.endDate;

    final String dateRangeText =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}'
        ' - '
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';

    final String currency = trip.currencyCode;
    final int dayCount = trip.totalDays;

    double? avgPerDay;
    if (dayCount > 0 && _totalExpenses > 0) {
      avgPerDay = _totalExpenses / dayCount;
    }

    final double? budget = trip.baseBudget;
    double? budgetProgress;
    double? budgetPercent;

    if (budget != null && budget > 0) {
      final ratio = _totalExpenses / budget;
      budgetProgress = ratio.clamp(0.0, 1.0);
      budgetPercent = (ratio * 100).clamp(0.0, 999.0);
    }

    final String smartTip = _buildSmartTip(
      totalExpenses: _totalExpenses,
      budget: budget,
      dayCount: dayCount,
    );

    final topCats = _topCategories();
        final topDay = _topSpendingDay();
    final double dailyAvg = avgPerDay ?? 0.0;
        final last7Spots = _last7DaysSpots();



    /// ✅ ΠΡΟΣΘΗΚΗ: category insight text
    final String categoryInsight = _buildCategoryInsightText(
      totalsByCategory: _totalsByCategory,
      totalExpenses: _totalExpenses,
      currency: currency,
    );

    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          // ✅ TripSummaryCard (πριν το Main Trip card)
          if (!_loading)
            _TripSummaryCard(
              trip: trip,
              totalExpenses: _totalExpenses,
              totalActivities: _activityCount,
            ),

          const SizedBox(height: 12),


          // 🔹 Main Trip card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title.isNotEmpty ? trip.title : trip.destination,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.destination,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(dateRangeText, style: const TextStyle(fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                currency,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        const Text(
                          'Trip summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'Total spent',
                                value: _totalExpenses > 0
                                    ? '${_totalExpenses.toStringAsFixed(2)} $currency'
                                    : '0 $currency',
                                icon: Icons.attach_money,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _SummaryCard(
                                label: 'Activities',
                                value: _activityCount.toString(),
                                icon: Icons.event_note,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'Days',
                                value: dayCount > 0 ? dayCount.toString() : '-',
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _SummaryCard(
                                label: 'Avg / day',
                                value: avgPerDay != null
                                    ? '${avgPerDay.toStringAsFixed(2)} $currency'
                                    : '-',
                                icon: Icons.trending_up,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (budget != null && budget > 0) ...[
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'Budget',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_totalExpenses.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)} $currency'
                            '${budgetPercent != null ? ' · ${budgetPercent.toStringAsFixed(0)}%' : ''}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: budgetProgress ?? 0.0,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ],
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Smart tip card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.blueGrey.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      smartTip,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 12),

          // ✅ Daily spending card
          if (!_loading)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily spending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Today',
                            value: '${_todayTotal.toStringAsFixed(0)} $currency',
                            icon: Icons.today,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Yesterday',
                            value:
                                '${_yesterdayTotal.toStringAsFixed(0)} $currency',
                            icon: Icons.history,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Daily avg (με βάση συνολικά / days)
                    if (dayCount > 0)
                      Text(
                        'Daily average: ${(avgPerDay ?? 0).toStringAsFixed(0)} $currency',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),

                    const SizedBox(height: 6),

                    Text(
                      _todayTotal > (avgPerDay ?? 0)
                          ? 'Tip: Today you spent more than your daily average. Consider cheaper choices for the rest of the day.'
                          : 'Tip: Today you are within your daily average. Keep it consistent to stay on track.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // ✅ Top spending day card
          if (!_loading && topDay != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_fire_department, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top spending day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${topDay.key}: ${topDay.value.toStringAsFixed(0)} $currency',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dailyAvg > 0
                                ? 'That’s ${(((topDay.value / dailyAvg) * 100) - 100).toStringAsFixed(0)}% above your daily average.'
                                : 'Add more expenses across days to compare averages.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


          const SizedBox(height: 12),

          // ✅ Last 7 days mini chart
          if (!_loading)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last 7 days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: last7Spots,
                              isCurved: true,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tip: Big spikes often come from transport, tours, or hotel payments.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),



          // ✅ Top categories card (κάτω από smart tip)
          const SizedBox(height: 12),
          if (!_loading && topCats.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top spending categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoriesBreakdownScreen(trip: trip),
                            ),
                          );
                        },
                        child: const Text('View all'),
                      ),
                    ),

                    ...topCats.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)} $currency',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          /// ✅ ΠΡΟΣΘΗΚΗ: Category insight card (κάτω από Top categories)
          const SizedBox(height: 12),
          if (!_loading && _totalsByCategory.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.green.withOpacity(0.06),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoryInsight,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          const Text(
            'More smart insights (AI suggestions, budget tips, itinerary optimization) '
            'will appear here as we connect the real AI API.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}






/// Μικρό card widget για τις τιμές summary
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TAB 2 – Itinerary με πραγματικά Activities από InMemoryActivityRepository.
class _ItineraryTab extends StatefulWidget {
  final Trip trip;

  const _ItineraryTab({required this.trip});

  @override
  State<_ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<_ItineraryTab>
    with AutomaticKeepAliveClientMixin {
  final InMemoryActivityRepository _activityRepo =
      InMemoryActivityRepository();

  /// Map<"yyyy-MM-dd", Map<DayPart, List<Activity>>>
  final Map<String, Map<DayPart, List<Activity>>> _activitiesByDay = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final all = await _activityRepo.getActivitiesForTrip(widget.trip);

    final Map<String, Map<DayPart, List<Activity>>> grouped =
        <String, Map<DayPart, List<Activity>>>{};

    for (final activity in all) {
      final date = activity.date;
      if (date == null) continue;

      final dayKey = _dayKey(date);
      final dayMap =
          grouped.putIfAbsent(dayKey, () => <DayPart, List<Activity>>{});

      final list =
          dayMap.putIfAbsent(activity.dayPart, () => <Activity>[]);
      list.add(activity);
    }

    setState(() {
      _activitiesByDay
        ..clear()
        ..addAll(grouped);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final trip = widget.trip;
    final start = trip.startDate;
    final end = trip.endDate;


    final int dayCount = end.difference(start).inDays + 1;
    if (dayCount <= 0) {
      return const Center(
        child: Text(
          'Invalid date range.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayCount,
      itemBuilder: (context, index) {
        final date = start.add(Duration(days: index));
        final dayLabel =
            'Day ${index + 1} – ${_formatDate(date)}'; // π.χ. Day 1 – 10/01/2025
        final dayKey = _dayKey(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDayPartSection(
                  context: context,
                  date: date,
                  dayKey: dayKey,
                  dayPart: DayPart.morning,
                  label: 'Morning',
                  icon: Icons.wb_sunny_outlined,
                ),
                const SizedBox(height: 8),
                _buildDayPartSection(
                  context: context,
                  date: date,
                  dayKey: dayKey,
                  dayPart: DayPart.afternoon,
                  label: 'Afternoon',
                  icon: Icons.light_mode_outlined,
                ),
                const SizedBox(height: 8),
                _buildDayPartSection(
                  context: context,
                  date: date,
                  dayKey: dayKey,
                  dayPart: DayPart.evening,
                  label: 'Evening',
                  icon: Icons.nightlight_outlined,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayPartSection({
    required BuildContext context,
    required DateTime date,
    required String dayKey,
    required DayPart dayPart,
    required String label,
    required IconData icon,
  }) {
    final list = _activitiesByDay[dayKey]?[dayPart] ?? <Activity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add activity',
              onPressed: () => _onAddActivityPressed(date, dayPart),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 26.0),
            child: Text(
              'No activities yet',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list.map((activity) {
                final cost = activity.estimatedCost;
                final currency = activity.currencyCode ?? '';
                final details = <String>[];

                if (activity.category != null &&
                    activity.category!.isNotEmpty) {
                  details.add(activity.category!);
                }
                if (cost != null && cost > 0) {
                  details.add(
                      '${cost.toStringAsFixed(0)} $currency');
                }

                return Dismissible(
                  key: ValueKey(activity.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return _confirmDeleteActivity(context);
                  },
                  onDismissed: (_) async {
                    await _activityRepo.deleteActivity(activity.id);
                    await _loadActivities();
                  },
child: InkWell(
  onTap: () async {
    final action = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ActivityDetailsBottomSheet(activity: activity),
    );

if (action == 'edit') {
  await _onAddActivityPressed(date, dayPart, existing: activity);
} else if (action == 'delete') {
      final ok = await _confirmDeleteActivity(context);
      if (ok == true) {
        await _activityRepo.deleteActivity(activity.id);
        await _loadActivities();
      }
    }
  },
  child: Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• '),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (activity.description != null &&
                  activity.description!.isNotEmpty)
                Text(
                  activity.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              if (details.isNotEmpty)
                Text(
                  details.join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  ),
),

                );
              }).toList(),
            ),
          ),
      ],
    );
  }

Future<void> _onAddActivityPressed(
  DateTime date,
  DayPart dayPart, {
  Activity? existing,
}) async {
  final result = await showModalBottomSheet<_NewActivityData>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return _AddActivitySheet(
        date: date,
        dayPart: dayPart,
        currencyCode: widget.trip.currencyCode,
      );
    },
  );

  if (result == null) return;

  final activity = Activity(
    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
    title: result.title,
    description: result.description,
    date: result.date,
    estimatedCost: result.estimatedCost,
    currencyCode: widget.trip.currencyCode,
    category: result.category,
    placeId: existing?.placeId,
    rating: existing?.rating,
    ratingCount: existing?.ratingCount,
    tripId: widget.trip.id,
    dayId: existing?.dayId,
    dayPart: dayPart,
  );

  if (existing != null) {
    await _activityRepo.updateActivity(activity);
  } else {
    await _activityRepo.addActivity(trip: widget.trip, activity: activity);
  }

  await _loadActivities();
}


  Future<bool> _confirmDeleteActivity(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete activity'),
          content: const Text(
              'Are you sure you want to delete this activity?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// TAB 3 – Expenses: χρήση του Expense model + InMemoryExpenseRepository.
class _ExpensesTab extends StatefulWidget {
  final Trip trip;

  const _ExpensesTab({required this.trip});

  @override
  State<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<_ExpensesTab>
    with AutomaticKeepAliveClientMixin {
  final InMemoryExpenseRepository _expenseRepo = InMemoryExpenseRepository();

  List<Expense> _expenses = <Expense>[];
  double _total = 0.0; // Σύνολο εξόδων για το trip
  bool _sortNewestFirst = true; // sort flag (true=newest first) //
String? _categoryFilter; // null = All categories //



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

Future<void> _loadExpenses() async { // load expenses //
  final List<Expense> list = await _expenseRepo.getExpensesForTrip(widget.trip); // fetch //
  final double total = await _expenseRepo.getTotalForTrip(widget.trip); // fetch total //

  // ✅ sort (newest/oldest) //
  list.sort((a, b) { // sort callback //
    return _sortNewestFirst // if newest //
        ? b.dateTime.compareTo(a.dateTime) // newest first //
        : a.dateTime.compareTo(b.dateTime); // oldest first //
  }); // end sort //

  // ✅ filter (category) //
  final List<Expense> filtered = _categoryFilter == null // if all //
      ? list // no filter //
      : list.where((e) => e.category == _categoryFilter).toList(); // filter by category //

  if (!mounted) return; // mounted guard //

  setState(() { // set state //
    _expenses = filtered; // set list shown //
    _total = total; // set total (still full total) //
  }); // end setState //
} // end load //


  @override
  Widget build(BuildContext context) {
    super.build(context); // σημαντικό λόγω keepAlive
    final currency = widget.trip.currencyCode;

    return Column(
      children: [
        // Σύνολο εξόδων
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
Column( // left header
  crossAxisAlignment: CrossAxisAlignment.start, // align
  children: [ // children
    const Text( // title
      'Total expenses', // text
      style: TextStyle( // style
        fontSize: 16, // size
        fontWeight: FontWeight.w600, // weight
      ), // end style
    ), // end title
    const SizedBox(height: 2), // gap
    Text( // count
      '${_expenses.length} items', // text
      style: TextStyle( // style
        fontSize: 12, // size
        color: Colors.grey[700], // color
      ), // end style
    ), // end count
  ], // end children
),

              Text(
                '${_total.toStringAsFixed(2)} $currency',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

Padding( // controls wrapper //
  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10), // padding //
  child: Row( // row //
    children: [ // children //
      // ✅ Sort chip //
      ChoiceChip( // chip //
        label: Text(_sortNewestFirst ? 'Newest' : 'Oldest'), // label //
        selected: true, // always highlighted //
        onSelected: (_) async { // on tap //
          setState(() => _sortNewestFirst = !_sortNewestFirst); // toggle //
          await _loadExpenses(); // reload //
        }, // end onSelected //
      ), // end chip //
      const SizedBox(width: 10), // gap //

      // ✅ Category filter chip (cycles) //
      ActionChip( // chip //
        label: Text(_categoryFilter ?? 'All categories'), // label //
        onPressed: () async { // on tap //
          final Set<String> catsSet = _expenses.map((e) => e.category).toSet(); // categories from current list //
          final List<String> cats = catsSet.toList()..sort(); // sort cats //
          final List<String?> options = <String?>[null, ...cats]; // first = All //
          final int currentIndex = options.indexOf(_categoryFilter); // current //
          final int nextIndex = (currentIndex + 1) % options.length; // next //
          setState(() => _categoryFilter = options[nextIndex]); // apply //
          await _loadExpenses(); // reload //
        }, // end onPressed //
      ), // end chip //
    ], // end children //
  ), // end row //
), // end padding //



        // Λίστα εξόδων ή μήνυμα κενό
        Expanded(
          child: _expenses.isEmpty
? Center( // empty state
    child: Padding( // padding
      padding: const EdgeInsets.all(24.0), // space
      child: Column( // column
        mainAxisSize: MainAxisSize.min, // compact
        children: [ // children
          Icon( // icon
            Icons.receipt_long, // receipt icon
            size: 48, // size
            color: Colors.blueGrey[400], // color
          ), // end icon
          const SizedBox(height: 12), // gap
          const Text( // title
            'No expenses yet', // text
            style: TextStyle( // style
              fontSize: 16, // size
              fontWeight: FontWeight.w600, // weight
            ), // end style
            textAlign: TextAlign.center, // align
          ), // end text
          const SizedBox(height: 6), // gap
          Text( // subtitle
            'Add your first expense to start tracking your spending.', // text
            style: TextStyle( // style
              fontSize: 13, // size
              color: Colors.grey[700], // color
            ), // end style
            textAlign: TextAlign.center, // align
          ), // end text
        ], // end children
      ), // end column
    ), // end padding
  ) // end center

              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final exp = _expenses[index];

                    return Dismissible(
                      key: ValueKey(exp.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        return _confirmDelete(context);
                      },
                      onDismissed: (_) async {
                        await _expenseRepo.deleteExpense(exp.id);
                        await _loadExpenses();
                      },

                      // ✅ TAP = EDIT
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
child: ListTile( // row expense
  onTap: () async { // tap = edit
    final bool? changed = await Navigator.of(context).push<bool>( // open edit
      MaterialPageRoute<bool>( // route
        builder: (_) => AddExpenseDemoScreen( // screen
          trip: widget.trip, // trip
          existingExpense: exp, // edit mode
        ), // end screen
      ), // end route
    ); // end push

    if (changed == true) { // if edited
      await _loadExpenses(); // refresh
    } // end if
  }, // end onTap

  leading: CircleAvatar( // leading icon bubble
    backgroundColor: Colors.blueGrey.withOpacity(0.10), // soft bg
    child: Icon( // icon
      _iconForCategory(exp.category), // icon by category
      size: 20, // size
      color: Colors.blueGrey[800], // color
    ), // end icon
  ), // end leading

  title: Text( // main title
    exp.category.isNotEmpty ? exp.category : 'Expense', // title text
    style: const TextStyle(fontWeight: FontWeight.w600), // style
  ), // end title

  subtitle: Padding( // compact subtitle
    padding: const EdgeInsets.only(top: 4.0), // spacing
    child: Wrap( // inline chips/text
      spacing: 8, // space
      runSpacing: 6, // wrap space
      crossAxisAlignment: WrapCrossAlignment.center, // align
      children: [ // children
        Text( // date
          _formatDateTime(exp.dateTime), // formatted date
          style: TextStyle(fontSize: 12, color: Colors.grey[700]), // style
        ), // end date
        if (_safeText(exp.paymentMethod).isNotEmpty) // payment exists
          Container( // chip
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // padding
            decoration: BoxDecoration( // box
              color: Colors.blueGrey.withOpacity(0.10), // bg
              borderRadius: BorderRadius.circular(999), // pill
            ), // end decoration
            child: Text( // text
              exp.paymentMethod!, // method
              style: TextStyle(fontSize: 11, color: Colors.grey[800]), // style
            ), // end text
          ), // end chip
        if (_safeText(exp.note).isNotEmpty) // note exists
          Text( // note
            exp.note!, // note
            style: TextStyle(fontSize: 12, color: Colors.grey[700]), // style
            overflow: TextOverflow.ellipsis, // ellipsis
          ), // end note
      ], // end children
    ), // end wrap
  ), // end subtitle

  trailing: Text( // amount
    '${exp.amount.toStringAsFixed(2)} $currency', // amount text
    style: const TextStyle(fontWeight: FontWeight.bold), // style
  ), // end trailing
), // end ListTile

                      ),
                    );
                  },
                ),
        ),

        // Κουμπί "Add expense"
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onAddExpensePressed,
                icon: const Icon(Icons.add),
                label: const Text('Add expense'),
              ),
            ),
          ),
        ),
      ],
    );
  }

 Future<void> _onAddExpensePressed() async {
  final result = await showModalBottomSheet<_NewExpenseData>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _AddExpenseSheet(
        currencyCode: widget.trip.currencyCode,
      );
    },
  );

  if (result == null) return;

  final newExpense = Expense(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    tripId: widget.trip.id,
    dateTime: result.createdAt,
    amount: result.amount,
    currencyCode: widget.trip.currencyCode,
    category: result.description,
    paymentMethod: result.paymentMethod,
    note: result.note,
  );

  await _expenseRepo.addExpense(
    trip: widget.trip,
    expense: newExpense,
  );

  await _loadExpenses();
}


  static String _formatDateTime(DateTime dt) {
    final d = '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
    final t = '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
    return '$d $t';
  }

  IconData _iconForCategory(String category) { // icon ανά κατηγορία
  final c = category.toLowerCase().trim(); // normalize
  if (c.contains('food')) return Icons.restaurant; // Food
  if (c.contains('transport')) return Icons.directions_bus; // Transport
  if (c.contains('hotel')) return Icons.hotel; // Hotel
  if (c.contains('tours')) return Icons.tour; // Tours
  if (c.contains('shopping')) return Icons.shopping_bag; // Shopping
  if (c.contains('coffee')) return Icons.local_cafe; // Coffee
  return Icons.payments; // default
} // end

String _safeText(String? v) => (v ?? '').trim(); // safe string helper


  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _ExpenseDetailsSheet extends StatelessWidget {
  final Trip trip;
  final Expense expense;

  const _ExpenseDetailsSheet({
    required this.trip,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final currency = trip.currencyCode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const Text(
            'Expense details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _detailRow('Category', expense.category),
          _detailRow('Amount', '${expense.amount.toStringAsFixed(2)} $currency'),
          _detailRow('Date', _formatDateTime(expense.dateTime)),

          if (expense.paymentMethod != null && expense.paymentMethod!.isNotEmpty)
            _detailRow('Payment', expense.paymentMethod!),

          if (expense.note != null && expense.note!.isNotEmpty)
            _detailRow('Note', expense.note!),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () async {
                    // Κλείνουμε το sheet πρώτα
                    Navigator.of(context).pop();

                    // Ανοίγουμε edit screen
                    final bool? changed =
                        await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => AddExpenseDemoScreen(
                          trip: trip,
                          existingExpense: expense,
                        ),
                      ),
                    );

                    // Αν άλλαξε, ξανα-ανοίγουμε sheet αποτέλεσμα στον caller μέσω pop(true)
                    // Δεν έχουμε context πλέον του sheet, οπότε απλά επιστρέφουμε change στον caller
                    // Ο caller θα κάνει refresh.
                    if (changed == true) {
                      // στέλνουμε σήμα refresh (θα το πιάσει το onLongPress block)
                      // NOTE: αυτό γίνεται από το screen που άνοιξε, άρα θα το χειριστεί ο caller με _loadExpenses()
                      // (το refresh γίνεται ήδη με το changed == true στο onTap / onLongPress wrapper)
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final bool ok = await _confirmDelete(context);
                    if (!ok) return;

                    await InMemoryExpenseRepository().deleteExpense(expense.id);

                    if (context.mounted) {
                      Navigator.of(context).pop(true); // ✅ ενημερώνει τον caller να κάνει refresh
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d $t';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}




/// Δεδομένα που επιστρέφει το bottom sheet πριν γίνουν Expense.
class _NewExpenseData {
  final double amount;
  final String description; // θα το βάλουμε στο category
  final DateTime createdAt;
  final String? paymentMethod;
  final String? note;

  _NewExpenseData({
    required this.amount,
    required this.description,
    required this.createdAt,
    this.paymentMethod,
    this.note,
  });
}

/// Μικρό bottom sheet για προσθήκη εξόδου (ποσό + περιγραφή + μέθοδος πληρωμής + σημείωση).
class _AddExpenseSheet extends StatefulWidget {
  final String currencyCode;

  const _AddExpenseSheet({required this.currencyCode});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const paymentMethods = <String>[
      'Cash',
      'Card',
      'Revolut',
      'Bank transfer',
      'Other',
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (${widget.currencyCode})',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed =
                        double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Dinner, taxi, tickets...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment method (optional)',
                  ),
                  items: paymentMethods
                      .map(
                        (m) => DropdownMenuItem<String>(
                          value: m,
                          child: Text(m),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. restaurant name, booking ref...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _onSavePressed,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final amount =
        double.parse(_amountController.text.trim().replaceAll(',', '.'));
    final desc = _descriptionController.text.trim();
    final noteText = _noteController.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    final data = _NewExpenseData(
      amount: amount,
      description: desc,
      createdAt: DateTime.now(),
      paymentMethod: _selectedPaymentMethod,
      note: note,
    );

    Navigator.of(context).pop(data);
  }
}

/// Δεδομένα που επιστρέφει το bottom sheet πριν γίνουν Activity.
class _NewActivityData {
  final String title;
  final String? description;
  final DateTime date;
  final double? estimatedCost;
  final String? category;

  _NewActivityData({
    required this.title,
    required this.date,
    this.description,
    this.estimatedCost,
    this.category,
  });
}

/// Bottom sheet για προσθήκη Activity σε συγκεκριμένη μέρα + day part.
class _AddActivitySheet extends StatefulWidget {
  final DateTime date;
  final DayPart dayPart;
  final String currencyCode;

  const _AddActivitySheet({
    required this.date,
    required this.dayPart,
    required this.currencyCode,
  });

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    String labelForDayPart(DayPart dayPart) {
      switch (dayPart) {
        case DayPart.morning:
          return 'Morning';
        case DayPart.afternoon:
          return 'Afternoon';
        case DayPart.evening:
          return 'Evening';
      }
    }

    final dayPartLabel = labelForDayPart(widget.dayPart);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add activity – $dayPartLabel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${widget.date.day.toString().padLeft(2, '0')}/'
                  '${widget.date.month.toString().padLeft(2, '0')}/'
                  '${widget.date.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Big Buddha, Island hopping, Night market...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Short notes about the activity',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'e.g. Beach, Food, Culture...',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        'Estimated cost (${widget.currencyCode}) (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _onSavePressed,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final costText = _costController.text.trim();

    double? estimatedCost;
    if (costText.isNotEmpty) {
      estimatedCost =
          double.tryParse(costText.replaceAll(',', '.')) ?? 0.0;
    }

    final data = _NewActivityData(
      title: title,
      description: desc.isEmpty ? null : desc,
      date: widget.date,
      estimatedCost: estimatedCost,
      category: category.isEmpty ? null : category,
    );

    Navigator.of(context).pop(data);
  }



  
}

/// Κάρτα σύνοψης για το ταξίδι στο Overview tab.
/// ΠΡΟΣΩΡΙΝΑ: θα την φτιάξουμε με placeholders.
/// Στο επόμενο βήμα θα της περάσουμε πραγματικά data από repos.
class _TripSummaryCard extends StatelessWidget {
  final Trip trip;                     // Το trip για το οποίο δείχνουμε σύνοψη
  final double totalExpenses;          // Σύνολο εξόδων του trip
  final int totalActivities;           // Πλήθος δραστηριοτήτων

  const _TripSummaryCard({
    super.key,
    required this.trip,
    required this.totalExpenses,
    required this.totalActivities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Τίτλος + προορισμός
            Text(
              trip.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trip.destination,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),

            // Ημερομηνίες + συνολικές μέρες
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${trip.startDate.toLocal().toString().split(' ').first}  →  ${trip.endDate.toLocal().toString().split(' ').first}',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${trip.totalDays} days',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Σειρά με συνολικά έξοδα & activities
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total spent',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalExpenses.toStringAsFixed(0)} ${trip.currencyCode}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activities',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalActivities',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Placeholder για μελλοντική AI πρόταση
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI tip: Spend a bit less on food tomorrow and try a local free activity.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
