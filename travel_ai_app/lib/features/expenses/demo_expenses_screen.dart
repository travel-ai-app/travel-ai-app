import 'package:flutter/material.dart'; // Flutter UI
import '../../core/mock/mock_data.dart'; // Demo δεδομένα (trip + expenses)
import '../../core/models/expense.dart'; // Μοντέλο Expense
import '../../core/models/trip.dart'; // Μοντέλο Trip
import 'add_expense_demo_screen.dart'; // Φόρμα προσθήκης demo εξόδου

class DemoExpensesScreen extends StatefulWidget { // Stateful οθόνη για να κάνουμε refresh
  const DemoExpensesScreen({super.key}); // Constructor

  @override // Υπερσκίαση createState
  State<DemoExpensesScreen> createState() => _DemoExpensesScreenState(); // Δημιουργία state
} // Τέλος DemoExpensesScreen

class _DemoExpensesScreenState extends State<DemoExpensesScreen> { // State κλάση
  bool _hasAddedExpense = false; // Flag για να ξέρουμε αν προστέθηκε έξοδο όσο ήμασταν εδώ

  @override // Υπερσκίαση build
  Widget build(BuildContext context) { // Δημιουργία UI
    final Trip trip = MockData.demoTrip; // Παίρνουμε το demo ταξίδι
    final List<Expense> expenses = MockData.demoExpenses; // Παίρνουμε τη λίστα demo εξόδων
    final double totalExpenses = MockData.totalDemoExpensesThb; // Σύνολο εξόδων
    final double baseBudget = trip.baseBudget ?? 0; // Budget ή 0 αν είναι null
    final double remaining = baseBudget - totalExpenses; // Υπόλοιπο

    return WillPopScope( // Για να ελέγχουμε τι θα επιστρέψουμε όταν κάνουμε back
      onWillPop: () async { // Όταν πατηθεί back (system ή app bar)
        Navigator.of(context).pop(_hasAddedExpense); // Επιστρέφουμε true/false στον caller
        return false; // Δεν αφήνουμε το default pop, το χειριστήκαμε εμείς
      }, // Τέλος onWillPop
      child: Scaffold( // Βασικό scaffold
        appBar: AppBar( // Πάνω μπάρα
          title: const Text('Demo Trip Expenses'), // Τίτλος
          centerTitle: true, // Κεντραρισμένος
        ), // Τέλος AppBar
        body: ListView.builder( // Scrollable λίστα
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Περιθώρια
          itemCount: expenses.length + 1, // +1 για το summary στην αρχή
          itemBuilder: (BuildContext context, int index) { // Builder για κάθε row
            if (index == 0) { // Πρώτη γραμμή = summary card
              return _buildSummaryCard( // Επιστροφή summary
                baseBudget, // Budget
                totalExpenses, // Συνολικά έξοδα
                remaining, // Υπόλοιπο
                trip.currencyCode, // Νόμισμα
              ); // Τέλος _buildSummaryCard
            } // Τέλος if index == 0

            final Expense expense = expenses[index - 1]; // Το σωστό έξοδο (offset -1)

            return Card( // Card γύρω από το κάθε έξοδο
              margin: const EdgeInsets.symmetric(vertical: 6), // Κάθετο margin
              child: ListTile( // Γραμμή λίστας
                leading: const Icon(Icons.payments), // Εικονίδιο
                title: Text( // Τίτλος
                  '${expense.category} · ${expense.amount.toStringAsFixed(0)} ${expense.currencyCode}', // Κατηγορία + ποσό + νόμισμα
                ), // Τέλος title
                subtitle: Text( // Δευτερεύον κείμενο
                  expense.note ?? 'No note', // Σημείωση ή default
                ), // Τέλος subtitle
                trailing: Text( // Κείμενο δεξιά
                  _formatDate(expense.dateTime), // Μορφοποιημένη ημερομηνία/ώρα
                  style: const TextStyle(fontSize: 12), // Μικρή γραμματοσειρά
                ), // Τέλος trailing
              ), // Τέλος ListTile
            ); // Τέλος Card
          }, // Τέλος itemBuilder
        ), // Τέλος ListView.builder
        floatingActionButton: FloatingActionButton( // Κουμπί +
          onPressed: () async { // Όταν πατηθεί
            final bool? added = await Navigator.of(context).push<bool>( // Ανοίγουμε τη φόρμα AddExpenseDemoScreen
              MaterialPageRoute<bool>( // Route
                builder: (BuildContext context) => const AddExpenseDemoScreen(), // Φόρμα προσθήκης
              ), // Τέλος MaterialPageRoute
            ); // Τέλος push

            if (added == true) { // Αν όντως προστέθηκε έξοδο
              _hasAddedExpense = true; // Σημειώνουμε ότι κάτι προστέθηκε
              setState(() {}); // Κάνουμε rebuild για να φανεί και στη λίστα/summary
            } // Τέλος if
          }, // Τέλος onPressed
          child: const Icon(Icons.add), // Εικονίδιο +
        ), // Τέλος FloatingActionButton
      ), // Τέλος Scaffold
    ); // Τέλος WillPopScope
  } // Τέλος build

  Widget _buildSummaryCard( // Widget για το summary Budget/Spent/Remaining
      double baseBudget, // Budget
      double totalExpenses, // Σύνολο εξόδων
      double remaining, // Υπόλοιπο
      String currencyCode, // Νόμισμα
      ) { // Άνοιγμα _buildSummaryCard
    final bool isOver = remaining < 0; // Αν ξεπεράσαμε το budget
    final String remainingLabel = isOver ? 'Over budget' : 'Remaining'; // Ετικέτα
    final String remainingValue = _formatAmount(remaining.abs(), currencyCode); // Πάντα θετικό ποσό

    return Card( // Card
      margin: const EdgeInsets.symmetric(vertical: 8), // Margin
      child: Padding( // Εσωτερικό padding
        padding: const EdgeInsets.all(16), // Όλα 16
        child: Column( // Κάθετη διάταξη
          crossAxisAlignment: CrossAxisAlignment.start, // Αριστερά
          children: <Widget>[ // Παιδιά
            const Text( // Τίτλος summary
              'Trip budget summary', // Κείμενο
              style: TextStyle( // Στυλ
                fontSize: 16, // Μέγεθος
                fontWeight: FontWeight.bold, // Έντονο
              ), // Τέλος style
            ), // Τέλος Text
            const SizedBox(height: 8), // Κενό
            Row( // Γραμμή με 3 πεδία
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Απόσταση
              children: <Widget>[ // Παιδιά
                _buildSummaryItem( // Πρώτο: Budget
                  'Budget', // Label
                  _formatAmount(baseBudget, currencyCode), // Value
                ), // Τέλος summary item
                _buildSummaryItem( // Δεύτερο: Spent
                  'Spent', // Label
                  _formatAmount(totalExpenses, currencyCode), // Value
                ), // Τέλος summary item
                _buildSummaryItem( // Τρίτο: Remaining / Over
                  remainingLabel, // Label
                  remainingValue, // Value
                  isWarning: isOver, // Αν θα γίνει κόκκινο
                ), // Τέλος summary item
              ], // Τέλος children
            ), // Τέλος Row
          ], // Τέλος children Column
        ), // Τέλος Column
      ), // Τέλος Padding
    ); // Τέλος Card
  } // Τέλος _buildSummaryCard

  Widget _buildSummaryItem( // Μικρό widget για Budget / Spent / Remaining
      String label, // Ετικέτα
      String value, { // Τιμή
        bool isWarning = false, // Αν είναι warning
      }) { // Άνοιγμα _buildSummaryItem
    return Column( // Κάθετη διάταξη
      crossAxisAlignment: CrossAxisAlignment.start, // Αριστερά
      children: <Widget>[ // Παιδιά
        Text( // Label
          label, // Κείμενο
          style: const TextStyle( // Στυλ
            fontSize: 12, // Μέγεθος
            color: Colors.grey, // Γκρι
          ), // Τέλος style
        ), // Τέλος Text
        const SizedBox(height: 4), // Κενό
        Text( // Value
          value, // Κείμενο
          style: TextStyle( // Στυλ
            fontSize: 14, // Μέγεθος
            fontWeight: FontWeight.w600, // Μισό-έντονο
            color: isWarning ? Colors.red : Colors.black, // Κόκκινο αν warning
          ), // Τέλος style
        ), // Τέλος Text
      ], // Τέλος children
    ); // Τέλος Column
  } // Τέλος _buildSummaryItem

  static String _formatAmount(double amount, String currencyCode) { // Format ποσού
    return '${amount.toStringAsFixed(0)} $currencyCode'; // Π.χ. "60000 THB"
  } // Τέλος _formatAmount

  static String _formatDate(DateTime dateTime) { // Μορφοποίηση ημερομηνίας/ώρας
    final String day = dateTime.day.toString().padLeft(2, '0'); // Ημέρα
    final String month = dateTime.month.toString().padLeft(2, '0'); // Μήνας
    final String year = dateTime.year.toString(); // Έτος
    final String hour = dateTime.hour.toString().padLeft(2, '0'); // Ώρα
    final String minute = dateTime.minute.toString().padLeft(2, '0'); // Λεπτά
    return '$day/$month/$year $hour:$minute'; // π.χ. "20/11/2025 15:30"
  } // Τέλος _formatDate
} // Τέλος _DemoExpensesScreenState
