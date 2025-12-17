import 'package:flutter/material.dart';
import 'package:travel_ai_app/core/models/activity.dart';

class ActivityDetailsBottomSheet extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsBottomSheet({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final cost = activity.estimatedCost;
    final currency = activity.currencyCode ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (activity.description != null && activity.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(activity.description!),
              ),
            const SizedBox(height: 12),
            if (activity.category != null && activity.category!.isNotEmpty)
              Text('Category: ${activity.category!}'),
            if (cost != null && cost > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Estimated cost: ${cost.toStringAsFixed(0)} $currency'),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => Navigator.pop(context, 'edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                    onPressed: () => Navigator.pop(context, 'delete'),
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
