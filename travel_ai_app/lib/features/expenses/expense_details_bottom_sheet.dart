import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_ai_app/core/models/expense.dart';

class ExpenseDetailsBottomSheet extends StatefulWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const ExpenseDetailsBottomSheet({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ExpenseDetailsBottomSheet> createState() =>
      _ExpenseDetailsBottomSheetState();
}

class _ExpenseDetailsBottomSheetState extends State<ExpenseDetailsBottomSheet> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;

    return SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.only(
      left: 16, // left //
      right: 16, // right //
      top: 16, // top //
      bottom: 16 + MediaQuery.of(context).viewInsets.bottom, // keyboard safe //
    ), // padding //
    child: Column(
      mainAxisSize: MainAxisSize.min, // fit //
      crossAxisAlignment: CrossAxisAlignment.start, // start //
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // spaced //
          children: [
            const Text(
              'Expense Details', // title //
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // style //
            ), // title //
            IconButton(
              icon: const Icon(Icons.close), // close //
              onPressed: _isDeleting ? null : () => Navigator.pop(context), // disable while deleting //
            ), // icon button //
          ], // children //
        ), // row //
        const SizedBox(height: 16), // gap //

        // Amount (prominent)
        Text(
          '${expense.amount.toStringAsFixed(2)} ${expense.currencyCode}', // amount + currency //
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), // style //
        ), // amount //
        const SizedBox(height: 16), // gap //

        // Category (dynamic icon)
        _buildInfoRow(
          icon: _categoryIcon(expense.category), // icon //
          label: 'Category', // label //
          value: expense.category, // value //
        ), // row //
        const SizedBox(height: 12), // gap //

        // Payment method (if available)
        if (expense.paymentMethod != null && expense.paymentMethod!.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.payment, // icon //
            label: 'Payment Method', // label //
            value: expense.paymentMethod!, // value //
          ), // row //
          const SizedBox(height: 12), // gap //
        ], // conditional //

        // Date and time
        _buildInfoRow(
          icon: Icons.access_time, // icon //
          label: 'Date & Time', // label //
          value: _formatDateTime(expense.dateTime), // value //
        ), // row //
        const SizedBox(height: 12), // gap //

        // Note (if available)
        if (expense.note != null && expense.note!.isNotEmpty) ...[
          const Divider(), // divider //
          const SizedBox(height: 8), // gap //
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // start //
            children: [
              Icon(Icons.note, size: 20, color: Colors.grey[600]), // icon //
              const SizedBox(width: 12), // gap //
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // start //
                  children: [
                    Text(
                      'Note', // label //
                      style: TextStyle(
                        fontSize: 12, // size //
                        color: Colors.grey[600], // color //
                        fontWeight: FontWeight.w500, // weight //
                      ), // style //
                    ), // label //
                    const SizedBox(height: 4), // gap //
                    Text(
                      expense.note!, // note //
                      style: const TextStyle(fontSize: 14), // style //
                    ), // note //
                  ], // children //
                ), // column //
              ), // expanded //
            ], // children //
          ), // row //
          const SizedBox(height: 8), // gap //
        ], // conditional //

        const SizedBox(height: 24), // gap //

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit), // icon //
                label: const Text('Edit'), // label //
                onPressed: _isDeleting
                    ? null
                    : () {
                        HapticFeedback.selectionClick(); // haptic //
                        Navigator.of(context).pop(); // close sheet //
                        Future.microtask(widget.onEdit); // then edit //
                      }, // onPressed //
              ), // button //
            ), // expanded //
            const SizedBox(width: 12), // gap //
            Expanded(
              child: OutlinedButton.icon(
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18, // size //
                        height: 18, // size //
                        child: CircularProgressIndicator(strokeWidth: 2), // loader //
                      ) // loader box //
                    : const Icon(Icons.delete, color: Colors.red), // delete icon //
                label: Text(
                  _isDeleting ? 'Deleting...' : 'Delete', // label //
                  style: const TextStyle(color: Colors.red), // style //
                ), // label //
                onPressed: _isDeleting ? null : () => _handleDelete(context), // delete //
              ), // button //
            ), // expanded //
          ], // children //
        ), // row //
      ], // children //
    ), // column //
  ), // scroll //
); // safe area //

  }

  // Category -> Icon mapping (English + a few Greek keywords)
  IconData _categoryIcon(String category) {
    final c = category.trim().toLowerCase();

    // Food / coffee
    if (c.contains('food') ||
        c.contains('restaurant') ||
        c.contains('coffee') ||
        c.contains('φαγη') ||
        c.contains('καφε')) {
      return Icons.restaurant;
    }

    // Transport
    if (c.contains('transport') ||
        c.contains('taxi') ||
        c.contains('uber') ||
        c.contains('bus') ||
        c.contains('metro') ||
        c.contains('μεταφορ') ||
        c.contains('ταξι')) {
      return Icons.directions_car;
    }

    // Hotel / stay
    if (c.contains('hotel') ||
        c.contains('stay') ||
        c.contains('accommodation') ||
        c.contains('lodging') ||
        c.contains('ξενοδοχ') ||
        c.contains('διαμον')) {
      return Icons.hotel;
    }

    // Shopping
    if (c.contains('shopping') ||
        c.contains('clothes') ||
        c.contains('market') ||
        c.contains('shop') ||
        c.contains('αγορ') ||
        c.contains('ρουχ')) {
      return Icons.shopping_bag;
    }

    // Groceries / supermarket
    if (c.contains('grocery') ||
        c.contains('grocer') ||
        c.contains('supermarket') ||
        c.contains('groceries') ||
        c.contains('σουπερ') ||
        c.contains('παντοπ')) {
      return Icons.local_grocery_store;
    }

    // Entertainment
    if (c.contains('entertain') ||
        c.contains('movie') ||
        c.contains('cinema') ||
        c.contains('bar') ||
        c.contains('club') ||
        c.contains('διασκεδ') ||
        c.contains('σινεμ') ||
        c.contains('μπαρ')) {
      return Icons.local_bar;
    }

    // Health
    if (c.contains('health') ||
        c.contains('pharmacy') ||
        c.contains('doctor') ||
        c.contains('hospital') ||
        c.contains('φαρμακ') ||
        c.contains('γιατρ') ||
        c.contains('νοσοκ')) {
      return Icons.local_hospital;
    }

    return Icons.category;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date • $time';
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isDeleting
                ? null
                : () {
                    HapticFeedback.mediumImpact(); // haptic on confirm
                    Navigator.pop(ctx, true); // close dialog with true
                  },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      setState(() => _isDeleting = true);
    }

    try {
      await widget.onDelete();

      if (context.mounted) {
        Navigator.pop(context); // close sheet after delete
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
