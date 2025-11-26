import 'package:flutter/material.dart'; // Βασικό Flutter UI
import '../../core/mock/mock_data.dart'; // Demo δεδομένα (trip + expenses)
import '../../core/models/trip.dart'; // Μοντέλο Trip
import '../../core/models/expense.dart'; // Μοντέλο Expense
import '../expenses/demo_expenses_screen.dart'; // Οθόνη demo εξόδων

class DemoTripOverviewScreen extends StatelessWidget { // Οθόνη επισκόπησης ταξιδιού
  const DemoTripOverviewScreen({super.key}); // Constructor με key

  @override // Υπερσκίαση build
  Widget build(BuildContext context) { // Δημιουργία UI
    final Trip trip = MockData.demoTrip; // Παίρνουμε το demo ταξίδι
    final List<Expense> expenses = MockData.demoExpenses; // Παίρνουμε τα demo έξοδα
    final double totalExpenses = MockData.totalDemoExpensesThb; // Σύνολο εξόδων
    final double baseBudget = trip.baseBudget ?? 0; // Budget ή 0 αν είναι null
    final double remaining = baseBudget - totalExpenses; // Υπόλοιπο
    final bool isOver = remaining < 0; // Αν είναι πάνω από budget

    return Scaffold( // Βασικό scaffold της σελίδας
      appBar: AppBar( // Πάνω μπάρα
        title: const Text('Demo Trip Overview'), // Τίτλος της σελίδας
        centerTitle: true, // Κεντραρισμένος τίτλος
      ), // Τέλος AppBar
      body: Padding( // Περιθώριο γύρω από το περιεχόμενο
        padding: const EdgeInsets.all(16), // Όλα 16
        child: Column( // Κάθετη διάταξη
          crossAxisAlignment: CrossAxisAlignment.start, // Στοίχιση αριστερά
          children: <Widget>[ // Λίστα από widgets
            Text( // Τίτλος ταξιδιού
              trip.title, // Π.χ. "Thailand Escape"
              style: const TextStyle( // Στυλ τίτλου
                fontSize: 22, // Μέγεθος γραμματοσειράς
                fontWeight: FontWeight.bold, // Έντονα
              ), // Τέλος style
            ), // Τέλος Text
            const SizedBox(height: 4), // Κενό
            Text( // Προορισμός
              trip.destination, // Π.χ. "Phuket, Thailand"
              style: const TextStyle( // Στυλ προορισμού
                fontSize: 16, // Μέγεθος
                color: Colors.grey, // Γκρι χρώμα
              ), // Τέλος style
            ), // Τέλος Text
            const SizedBox(height: 8), // Κενό
            Text( // Ημερομηνίες ταξιδιού
              _formatTripDates(trip), // "20/11/2025 - 27/11/2025"
              style: const TextStyle( // Στυλ ημερομηνιών
                fontSize: 14, // Μέγεθος
              ), // Τέλος style
            ), // Τέλος Text
            const SizedBox(height: 16), // Κενό

            Card( // Κάρτα για συνοπτικό budget
              child: Padding( // Εσωτερικό padding
                padding: const EdgeInsets.all(16), // Padding
                child: Row( // Γραμμή με 3 στήλες
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Απόσταση
                  children: <Widget>[ // Παιδιά row
                    _buildInfoColumn( // Πρώτη στήλη
                      'Budget', // Ετικέτα
                      _formatAmount(baseBudget, trip.currencyCode), // Ποσό
                    ), // Τέλος στήλης
                    _buildInfoColumn( // Δεύτερη στήλη
                      'Spent', // Ετικέτα
                      _formatAmount(totalExpenses, trip.currencyCode), // Ποσό εξόδων
                    ), // Τέλος στήλης
                    _buildInfoColumn( // Τρίτη στήλη
                      isOver ? 'Over budget' : 'Remaining', // Αν είναι πάνω από budget
                      _formatAmount(remaining.abs(), trip.currencyCode), // Ποσό υπολοίπου/υπέρβασης
                      isWarning: isOver, // Αν θα γίνει κόκκινο
                    ), // Τέλος στήλης
                  ], // Τέλος children
                ), // Τέλος Row
              ), // Τέλος Padding
            ), // Τέλος Card

            const SizedBox(height: 16), // Κενό

            Text( // Τίτλος για τα έξοδα
              'Recent expenses (${expenses.length})', // Π.χ. "Recent expenses (3)"
              style: const TextStyle( // Στυλ κειμένου
                fontSize: 16, // Μέγεθος
                fontWeight: FontWeight.w600, // Μισό-έντονα
              ), // Τέλος style
            ), // Τέλος Text

            const SizedBox(height: 8), // Κενό

            Expanded( // Λαμβάνει τον υπόλοιπο χώρο
              child: ListView.builder( // Λίστα με τα έξοδα
                itemCount: expenses.length, // Πλήθος εξόδων
                itemBuilder: (BuildContext context, int index) { // Builder
                  final Expense expense = expenses[index]; // Τρέχον έξοδο
                  return ListTile( // Γραμμή λίστας
                    leading: const Icon(Icons.payments), // Εικονίδιο
                    title: Text( // Τίτλος
                      '${expense.category} · ${expense.amount.toStringAsFixed(0)} ${expense.currencyCode}', // Κατηγορία + ποσό
                    ), // Τέλος title
                    subtitle: Text( // Δευτερεύον κείμενο
                      expense.note ?? 'No note', // Σημείωση
                    ), // Τέλος subtitle
                    trailing: Text( // Κείμενο δεξιά
                      _formatDate(expense.dateTime), // Ημερομηνία
                      style: const TextStyle(fontSize: 12), // Μικρή γραμματοσειρά
                    ), // Τέλος trailing
                  ); // Τέλος ListTile
                }, // Τέλος itemBuilder
              ), // Τέλος ListView.builder
            ), // Τέλος Expanded

            const SizedBox(height: 12), // Κενό

            SizedBox( // Κουμπί full width
              width: double.infinity, // Πιάνει όλο το πλάτος
              child: ElevatedButton( // Κουμπί
                onPressed: () { // Όταν πατηθεί
                  Navigator.of(context).push( // Πηγαίνει σε νέα οθόνη
                    MaterialPageRoute<Widget>( // Route τύπου Material
                      builder: (BuildContext context) =>
                          const DemoExpensesScreen(), // Ανοίγει την DemoExpensesScreen
                    ), // Τέλος MaterialPageRoute
                  ); // Τέλος push
                }, // Τέλος onPressed
                child: const Text('View full expenses list'), // Κείμενο στο κουμπί
              ), // Τέλος ElevatedButton
            ), // Τέλος SizedBox
          ], // Τέλος children column
        ), // Τέλος Column
      ), // Τέλος Padding
    ); // Τέλος Scaffold
  } // Τέλος build

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
