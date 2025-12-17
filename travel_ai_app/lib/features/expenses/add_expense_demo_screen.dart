import 'package:flutter/material.dart';

import '../../core/models/expense.dart';
import '../../core/models/trip.dart';
import '../../core/data/in_memory_expense_repository.dart';

class AddExpenseDemoScreen extends StatefulWidget {
  final Trip trip;
  final Expense? existingExpense; // αν υπάρχει → edit mode

  const AddExpenseDemoScreen({
    super.key,
    required this.trip,
    this.existingExpense,
  });

  @override
  State<AddExpenseDemoScreen> createState() => _AddExpenseDemoScreenState();
}

class _AddExpenseDemoScreenState extends State<AddExpenseDemoScreen> {
  final InMemoryExpenseRepository _repo = InMemoryExpenseRepository();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  String _category = 'Food';
  String? _paymentMethod;

  final List<String> _categories = <String>[
    'Food',
    'Transport',
    'Hotel',
    'Tours',
    'Shopping',
    'Coffee',
    'Other',
  ];

  final List<String> _paymentMethods = <String>[
    'Cash',
    'Card',
    'Revolut',
    'Other',
  ];

  bool get _isEdit => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();

final Expense? e = widget.existingExpense;
if (e != null) {
  _amountController.text = e.amount.toStringAsFixed(0);
  _noteController.text = e.note ?? '';
  _dateTime = e.dateTime;

  // ✅ Category safe prefill
  if (_categories.contains(e.category)) {
    _category = e.category;
  } else {
    _category = 'Other';
  }

  // ✅ Payment method safe prefill
  if (e.paymentMethod != null && _paymentMethods.contains(e.paymentMethod)) {
    _paymentMethod = e.paymentMethod;
  } else {
    _paymentMethod = null;
  }
}

  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initial = _dateTime;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay initial = TimeOfDay.fromDateTime(_dateTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return;

    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    final String amountText =
        _amountController.text.trim().replaceAll(',', '.');
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final String? note =
        _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    final Expense? old = widget.existingExpense;

    // ✅ Φτιάχνουμε το expense που θα σωθεί
    final Expense expenseToSave = Expense(
      id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      tripId: widget.trip.id,
      dateTime: _dateTime,
      amount: amount,
      currencyCode: widget.trip.currencyCode,
      category: _category,
      paymentMethod: _paymentMethod,
      note: note,
    );

    // ✅ EDIT mode: σβήνουμε το παλιό και προσθέτουμε το νέο (ίδιο id)
    if (old != null) {
      await _repo.deleteExpense(old.id);
    }

    // ✅ ADD (ή re-add μετά από edit)
    await _repo.addExpense(
      trip: widget.trip,
      expense: expenseToSave,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true); // true = έγινε αλλαγή
  }

  @override
  Widget build(BuildContext context) {
    final Trip trip = widget.trip;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (${trip.currencyCode})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Category
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: _categories
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _category = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Payment method
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Payment method (optional)',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _paymentMethod,
                isExpanded: true,
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('-'),
                  ),
                  ..._paymentMethods.map(
                    (p) => DropdownMenuItem<String?>(
                      value: p,
                      child: Text(p),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date + Time
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_dateTime.day.toString().padLeft(2, '0')}/${_dateTime.month.toString().padLeft(2, '0')}/${_dateTime.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Save
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(_isEdit ? 'Save changes' : 'Add expense'),
          ),
        ],
      ),
    );
  }
}
