import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/models/expense.dart';
import '../../core/models/trip.dart';
import 'add_expense_demo_screen.dart'; // ΝΕΟ import για την οθόνη προσθήκης

class DemoExpensesScreen extends StatelessWidget {
  const DemoExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Trip trip = MockData.demoTrip; // demo ταξίδι
    final List<Expense> expenses = MockData.demoExpenses; // demo έξοδα
    final double totalExpenses = MockData.totalDemoExpensesThb; // σύνολο
    final double baseBudget = trip.baseBudget ?? 0; // budget ή 0
    final double remaining = baseBudget - totalExpenses; // υπόλοιπο

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Trip Expenses'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: expenses.length + 1, // +1 για το summary στην αρχή
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildSummaryCard(
              baseBudget,
              totalExpenses,
              remaining,
              trip.currencyCode,
            );
          }

          final Expense expense = expenses[index - 1];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton( // ΝΕΟ κουμπί για προσθήκη εξόδου
        onPressed: () async {
          final bool? added = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (BuildContext context) =>
                  const AddExpenseDemoScreen(), // ανοίγει τη φόρμα
            ),
          );

          // Προαιρετικά στο μέλλον: αν added == true, μπορούμε να κάνουμε επιπλέον actions
          // Προς το παρόν, επειδή χρησιμοποιούμε MockData.demoExpenses,
          // όταν γυρνάμε πίσω η λίστα ξαναχτίζεται και βλέπει τα νέα δεδομένα.
        },
        child: const Icon(Icons.add), // εικονίδιο +
      ),
    );
  }

  Widget _buildSummaryCard(
    double baseBudget,
    double totalExpenses,
    double remaining,
    String currencyCode,
  ) {
    final bool isOver = remaining < 0;
    final String remainingLabel = isOver ? 'Over budget' : 'Remaining';
    final String remainingValue =
        _formatAmount(remaining.abs(), currencyCode);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Trip budget summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildSummaryItem(
                  'Budget',
                  _formatAmount(baseBudget, currencyCode),
                ),
                _buildSummaryItem(
                  'Spent',
                  _formatAmount(totalExpenses, currencyCode),
                ),
                _buildSummaryItem(
                  remainingLabel,
                  remainingValue,
                  isWarning: isOver,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
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

  static String _formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(0)} $currencyCode';
  }

  static String _formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
