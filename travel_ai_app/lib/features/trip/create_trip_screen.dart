import 'package:flutter/material.dart';                 // Βασικό Flutter πακέτο
import '../../core/models/trip.dart';                   // Μοντέλο Trip

/// Οθόνη δημιουργίας νέου ταξιδιού (Create Trip).
///
/// Επιστρέφει ένα [Trip] μέσω `Navigator.pop(trip)` όταν γίνει "Save".
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();             // Key για το Form

  final _titleController = TextEditingController();    // Τίτλος ταξιδιού
  final _destinationController = TextEditingController(); // Προορισμός

  DateTime? _startDate;                                // Ημερομηνία έναρξης
  DateTime? _endDate;                                  // Ημερομηνία λήξης

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),              // Τίτλος οθόνης
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),           // Λίγο κενό γύρω-γύρω
        child: Form(
          key: _formKey,                               // Σύνδεση του Form με το key
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip title',             // Π.χ. "Thailand with friends"
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',            // Π.χ. "Thailand"
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDatePickerRow(
                context: context,
                label: 'Start date',
                selectedDate: _startDate,
                onTap: () => _pickDate(isStart: true),
              ),
              const SizedBox(height: 12),
              _buildDatePickerRow(
                context: context,
                label: 'End date',
                selectedDate: _endDate,
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onSavePressed,
                child: const Text('Save trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Row με label + τρέχουσα τιμή ημερομηνίας + κουμπί επιλογής.
  Widget _buildDatePickerRow({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    final text = selectedDate == null
        ? 'Select date'
        : '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}';

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(text),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()));

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      setState(() {
        if (isStart) {
          _startDate = newDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate; // Αντιστραμμένες ημερομηνίες → ευθυγράμμιση
          }
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  void _onSavePressed() {
    final formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid) return;

    if (_startDate == null || _endDate == null) {
      _showError('Please select both start and end dates');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('End date cannot be before start date');
      return;
    }

    // Δημιουργούμε ένα Trip αντικείμενο με βάση τον constructor που ήδη έχεις:
    // required: id, title, destination, startDate, endDate, currencyCode
    final newTrip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}', // Απλό unique id
      title: _titleController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      currencyCode: 'EUR', // Προς το παρόν σταθερό. Αργότερα dropdown.
    );

    Navigator.of(context).pop(newTrip); // Επιστροφή του Trip στον caller
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
