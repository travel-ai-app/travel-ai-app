import 'package:flutter/material.dart'; // Βασικό Flutter UI
import '../../core/models/expense.dart'; // Μοντέλο Expense
import '../../core/mock/mock_data.dart'; // Demo δεδομένα (λίστα με έξοδα)
import '../../core/models/trip.dart'; // Μοντέλο Trip για το currency

class AddExpenseDemoScreen extends StatefulWidget { // Οθόνη προσθήκης demo εξόδου
  const AddExpenseDemoScreen({super.key}); // Constructor με key

  @override // Υπερσκίαση createState
  State<AddExpenseDemoScreen> createState() => _AddExpenseDemoScreenState(); // Δημιουργία state
} // Τέλος κλάσης AddExpenseDemoScreen

class _AddExpenseDemoScreenState extends State<AddExpenseDemoScreen> { // State κλάση
  final TextEditingController _amountController = TextEditingController(); // Controller για το ποσό
  final TextEditingController _noteController = TextEditingController(); // Controller για τη σημείωση

  final List<String> _categories = <String>[ // Διαθέσιμες κατηγορίες
    'Food', // Φαγητό
    'Hotel', // Ξενοδοχείο
    'Transport', // Μεταφορές
    'Activity', // Δραστηριότητα
    'Other', // Άλλο
  ]; // Τέλος λίστας κατηγοριών

  String _selectedCategory = 'Food'; // Επιλεγμένη κατηγορία (default)
  DateTime _selectedDateTime = DateTime.now(); // Επιλεγμένη ημερομηνία/ώρα (default τώρα)

  @override // Υπερσκίαση dispose
  void dispose() { // Καλείται όταν κλείνει το state
    _amountController.dispose(); // Καθαρίζει τον controller ποσού
    _noteController.dispose(); // Καθαρίζει τον controller σημείωσης
    super.dispose(); // Καλεί το super
  } // Τέλος dispose

  @override // Υπερσκίαση build
  Widget build(BuildContext context) { // Δημιουργία UI
    final Trip trip = MockData.demoTrip; // Παίρνουμε το demo trip για το currency
    final String currencyCode = trip.currencyCode; // Νόμισμα ταξιδιού (π.χ. THB)

    return Scaffold( // Βασικό scaffold
      appBar: AppBar( // Πάνω μπάρα
        title: const Text('Add demo expense'), // Τίτλος οθόνης
      ), // Τέλος AppBar
      body: Padding( // Περιθώριο γύρω από τη φόρμα
        padding: const EdgeInsets.all(16), // Padding 16
        child: Column( // Κάθετη διάταξη
          crossAxisAlignment: CrossAxisAlignment.start, // Στοίχιση αριστερά
          children: <Widget>[ // Παιδιά της στήλης
            TextField( // TextField για το ποσό
              controller: _amountController, // Συνδέουμε τον controller
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // Πληκτρολόγιο αριθμών
              decoration: InputDecoration( // Διακόσμηση πεδίου
                labelText: 'Amount ($currencyCode)', // Ετικέτα με νόμισμα
                border: const OutlineInputBorder(), // Γραμμή γύρω από το πεδίο
              ), // Τέλος decoration
            ), // Τέλος TextField ποσού
            const SizedBox(height: 12), // Κενό

            DropdownButtonFormField<String>( // Dropdown για κατηγορία
              value: _selectedCategory, // Τρέχουσα επιλεγμένη τιμή
              decoration: const InputDecoration( // Διακόσμηση
                labelText: 'Category', // Ετικέτα
                border: OutlineInputBorder(), // Γραμμή γύρω
              ), // Τέλος decoration
              items: _categories // Λίστα κατηγοριών
                  .map((String cat) => DropdownMenuItem<String>( // Map σε DropdownMenuItem
                        value: cat, // Τιμή
                        child: Text(cat), // Κείμενο
                      )) // Τέλος map
                  .toList(), // Μετατροπή σε λίστα
              onChanged: (String? newValue) { // Όταν αλλάζει η τιμή
                if (newValue == null) { // Αν είναι null
                  return; // Βγαίνουμε χωρίς αλλαγή
                } // Τέλος if
                setState(() { // Ενημέρωση state
                  _selectedCategory = newValue; // Αλλάζουμε την κατηγορία
                }); // Τέλος setState
              }, // Τέλος onChanged
            ), // Τέλος DropdownButtonFormField
            const SizedBox(height: 12), // Κενό

            TextField( // TextField για σημείωση
              controller: _noteController, // Controller σημείωσης
              decoration: const InputDecoration( // Διακόσμηση
                labelText: 'Note (optional)', // Ετικέτα
                border: OutlineInputBorder(), // Γραμμή γύρω
              ), // Τέλος decoration
              maxLines: 2, // Μέχρι 2 γραμμές
            ), // Τέλος TextField σημείωσης
            const SizedBox(height: 12), // Κενό

            Row( // Γραμμή για εμφάνιση ημερομηνίας/ώρας
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Απόσταση μεταξύ στοιχείων
              children: <Widget>[ // Παιδιά row
                Column( // Στήλη με κείμενα
                  crossAxisAlignment: CrossAxisAlignment.start, // Αριστερή στοίχιση
                  children: <Widget>[ // Παιδιά στήλης
                    const Text( // Τίτλος
                      'Date & time', // Κείμενο
                      style: TextStyle( // Στυλ
                        fontSize: 12, // Μέγεθος
                        color: Colors.grey, // Γκρι
                      ), // Τέλος style
                    ), // Τέλος Text
                    const SizedBox(height: 4), // Κενό
                    Text( // Εμφάνιση ημερομηνίας
                      _formatDateTime(_selectedDateTime), // Μορφοποιημένη ημερομηνία/ώρα
                      style: const TextStyle(fontSize: 14), // Στυλ
                    ), // Τέλος Text
                  ], // Τέλος children column
                ), // Τέλος Column
                TextButton( // Κουμπί για αλλαγή ημερομηνίας
                  onPressed: _pickDateTime, // Καλεί τη μέθοδο επιλογής ημερομηνίας
                  child: const Text('Change'), // Κείμενο κουμπιού
                ), // Τέλος TextButton
              ], // Τέλος children row
            ), // Τέλος Row

            const Spacer(), // Σπρώχνει το κουμπί κάτω

            SizedBox( // Container για το κουμπί
              width: double.infinity, // Πιάνει όλο το πλάτος
              child: ElevatedButton( // Κουμπί αποθήκευσης
                onPressed: _saveExpense, // Όταν πατηθεί, αποθηκεύει το έξοδο
                child: const Text('Save demo expense'), // Κείμενο στο κουμπί
              ), // Τέλος ElevatedButton
            ), // Τέλος SizedBox
          ], // Τέλος children column
        ), // Τέλος Column
      ), // Τέλος Padding
    ); // Τέλος Scaffold
  } // Τέλος build

  Future<void> _pickDateTime() async { // Επιλογή ημερομηνίας/ώρας
    final DateTime now = DateTime.now(); // Τρέχουσα ημερομηνία/ώρα
    final DateTime? pickedDate = await showDatePicker( // Διάλογος επιλογής ημερομηνίας
      context: context, // Context
      initialDate: _selectedDateTime, // Αρχική ημερομηνία
      firstDate: DateTime(now.year - 1), // Πρώτη επιτρεπτή
      lastDate: DateTime(now.year + 2), // Τελευταία επιτρεπτή
    ); // Τέλος showDatePicker

    if (pickedDate == null) { // Αν δεν επιλέχθηκε τίποτα
      return; // Βγαίνουμε
    } // Τέλος if

    final TimeOfDay? pickedTime = await showTimePicker( // Διάλογος επιλογής ώρας
      context: context, // Context
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime), // Αρχική ώρα
    ); // Τέλος showTimePicker

    if (pickedTime == null) { // Αν δεν επιλέχθηκε ώρα
      return; // Βγαίνουμε
    } // Τέλος if

    setState(() { // Ενημέρωση state
      _selectedDateTime = DateTime( // Νέα ημερομηνία/ώρα
        pickedDate.year, // Έτος
        pickedDate.month, // Μήνας
        pickedDate.day, // Ημέρα
        pickedTime.hour, // Ώρα
        pickedTime.minute, // Λεπτά
      ); // Τέλος DateTime
    }); // Τέλος setState
  } // Τέλος _pickDateTime

  Future<void> _saveExpense() async { // Αποθήκευση demo εξόδου
    final String amountText = _amountController.text.trim(); // Ποσό ως κείμενο
    if (amountText.isEmpty) { // Αν είναι κενό
      _showSnackBar('Please enter an amount'); // Μήνυμα λάθους
      return; // Σταματάμε
    } // Τέλος if

    final double? amount = double.tryParse(amountText); // Προσπαθούμε να το κάνουμε double
    if (amount == null || amount <= 0) { // Αν δεν είναι έγκυρο
      _showSnackBar('Please enter a valid positive amount'); // Μήνυμα λάθους
      return; // Σταματάμε
    } // Τέλος if

    final Trip trip = MockData.demoTrip; // Παίρνουμε το demo trip
    final String id = 'exp_demo_${DateTime.now().millisecondsSinceEpoch}'; // Δημιουργούμε μοναδικό ID
    final Expense newExpense = Expense( // Δημιουργία νέου Expense
      id: id, // ID
      tripId: trip.id, // Trip ID
      dateTime: _selectedDateTime, // Επιλεγμένη ημερομηνία/ώρα
      amount: amount, // Ποσό
      currencyCode: trip.currencyCode, // Νόμισμα
      category: _selectedCategory, // Κατηγορία
      paymentMethod: 'Demo', // Demo μέθοδος πληρωμής
      note: _noteController.text.trim().isEmpty // Αν η σημείωση είναι κενή
          ? null // Τότε null
          : _noteController.text.trim(), // Αλλιώς το κείμενο
    ); // Τέλος δημιουργίας newExpense

    MockData.demoExpenses.add(newExpense); // Προσθέτουμε το έξοδο στη demo λίστα

    _showSnackBar('Demo expense added'); // Εμφάνιση επιβεβαίωσης

    Navigator.of(context).pop(true); // Κλείνουμε την οθόνη και επιστρέφουμε true
  } // Τέλος _saveExpense

  void _showSnackBar(String message) { // Βοηθητική συνάρτηση για SnackBar
    ScaffoldMessenger.of(context).showSnackBar( // Εμφάνιση SnackBar
      SnackBar(content: Text(message)), // Κείμενο SnackBar
    ); // Τέλος SnackBar
  } // Τέλος _showSnackBar

  String _formatDateTime(DateTime dateTime) { // Μορφοποίηση ημερομηνίας/ώρας
    final String day = dateTime.day.toString().padLeft(2, '0'); // Ημέρα
    final String month = dateTime.month.toString().padLeft(2, '0'); // Μήνας
    final String year = dateTime.year.toString(); // Έτος
    final String hour = dateTime.hour.toString().padLeft(2, '0'); // Ώρα
    final String minute = dateTime.minute.toString().padLeft(2, '0'); // Λεπτά
    return '$day/$month/$year $hour:$minute'; // Π.χ. "20/11/2025 15:30"
  } // Τέλος _formatDateTime
} // Τέλος κλάσης _AddExpenseDemoScreenState
