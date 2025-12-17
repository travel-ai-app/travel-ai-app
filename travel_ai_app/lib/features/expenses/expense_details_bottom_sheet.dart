import 'package:flutter/material.dart';
import 'package:travel_ai_app/core/models/expense.dart';

class ExpenseDetailsBottomSheet extends StatelessWidget {
  final Expense expense; // το expense που πατήθηκε

  const ExpenseDetailsBottomSheet({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // bottom sheet να μην πιάνει όλη την οθόνη
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Amount
            Text(
              '${expense.amount.toStringAsFixed(2)} ${expense.currencyCode}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // ── Category
            Text(
              expense.category,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 12),

            // ── Note
            if (expense.note != null && expense.note!.isNotEmpty)
              Text(
                expense.note!,
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 20),

            // ── Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context, 'edit'); // επιστρέφουμε action
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                    onPressed: () {
                      Navigator.pop(context, 'delete');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
