import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/models/trip.dart';
import '../../core/models/expense.dart';
import '../expenses/demo_expenses_screen.dart';
import 'demo_itinerary_screen.dart'; // ΝΕΟ import

class DemoTripOverviewScreen extends StatefulWidget {
  const DemoTripOverviewScreen({super.key});

  @override
  State<DemoTripOverviewScreen> createState() =>
      _DemoTripOverviewScreenState();
}

class _DemoTripOverviewScreenState extends State<DemoTripOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final Trip trip = MockData.demoTrip;
    final List<Expense> expenses = MockData.demoExpenses;
    final double totalExpenses = MockData.totalDemoExpensesThb;
    final double baseBudget = trip.baseBudget ?? 0;
    final double remaining = baseBudget - totalExpenses;
    final bool isOver = remaining < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Trip Overview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ΤΙΤΛΟΣ ΤΑΞΙΔΙΟΥ
            Text(
              trip.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trip.destination,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTripDates(trip),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // ΚΟΥΜΠΙΑ: ITINERARY + FULL EXPENSES
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<Widget>(
                          builder: (BuildContext context) =>
                          const DemoItineraryScreen(),
                        ),
                      );
                    },
                    child: const Text('View itinerary'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final bool? added =
                      await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (BuildContext context) =>
                          const DemoExpensesScreen(),
                        ),
                      );
                      if (added == true) {
                        setState(() {}); // refresh overview όταν μπει νέο έξοδο
                      }
                    },
                    child: const Text('View expenses'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SUMMARY CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildInfoColumn(
                      'Budget',
                      _formatAmount(baseBudget, trip.currencyCode),
                    ),
                    _buildInfoColumn(
                      'Spent',
                      _formatAmount(totalExpenses, trip.currencyCode),
                    ),
                    _buildInfoColumn(
                      isOver ? 'Over budget' : 'Remaining',
                      _formatAmount(remaining.abs(), trip.currencyCode),
                      isWarning: isOver,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Recent expenses (${expenses.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (BuildContext context, int index) {
                  final Expense expense = expenses[index];
                  return ListTile(
                    leading: const Icon(Icons.payments),
                    title: Text(
                      '${expense.category} · ${expense.amount.toStringAsFixed(0)} ${expense.currencyCode}',
                    ),
                    subtitle: Text(
                      expense.note ?? 'No note',
                    ),
                    trailing: Text(
                      _formatDate(expense.dateTime),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      String label,
      String value, {
        bool isWarning = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isWarning ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  static String _formatTripDates(Trip trip) {
    final String start = _formatDate(trip.startDate);
    final String end = _formatDate(trip.endDate);
    return '$start - $end';
  }

  static String _formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(0)} $currencyCode';
  }

  static String _formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    return '$day/$month/$year';
  }
}
