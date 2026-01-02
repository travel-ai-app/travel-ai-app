import 'package:flutter/material.dart'; // UI //
import 'package:travel_ai_app/core/models/activity.dart'; // model //

enum ActivityDetailsAction {
  edit, // edit action //
  delete, // delete action //
}

class ActivityDetailsBottomSheet extends StatelessWidget {
  final Activity activity; // activity //

  const ActivityDetailsBottomSheet({
    super.key,
    required this.activity,
  }); // ctor //

  @override
  Widget build(BuildContext context) {
    final cost = activity.estimatedCost; // cost //
    final currency = activity.currencyCode ?? ''; // currency //

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // spaced //
              children: [
                const Text(
                  'Activity details', // title //
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // style //
                ), // title //
                IconButton(
                  icon: const Icon(Icons.close), // close //
                  onPressed: () => Navigator.pop(context), // close //
                ), // close btn //
              ], // children //
            ), // header row //
            const SizedBox(height: 12), // gap //

            Text(
              activity.title, // title //
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // style //
            ), // title //
            if (activity.description != null && activity.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8), // pad //
                child: Text(activity.description!), // desc //
              ), // desc //

            const SizedBox(height: 12), // gap //

            if (activity.category != null && activity.category!.isNotEmpty)
              Text('Category: ${activity.category!}'), // category //

            if (cost != null && cost > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6), // pad //
                child: Text('Estimated cost: ${cost.toStringAsFixed(0)} $currency'), // cost //
              ), // cost //

            const SizedBox(height: 20), // gap //

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit), // icon //
                    label: const Text('Edit'), // label //
                    onPressed: () => Navigator.pop(context, ActivityDetailsAction.edit), // return action //
                  ), // btn //
                ), // expanded //
                const SizedBox(width: 12), // gap //
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red), // icon //
                    label: const Text('Delete', style: TextStyle(color: Colors.red)), // red label //
                    onPressed: () async {
  final confirmed = await showDialog<bool>(
    context: context, // ctx //
    builder: (ctx) => AlertDialog(
      title: const Text('Delete activity?'), // title //
      content: const Text('This action cannot be undone.'), // content //
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false), // cancel //
          child: const Text('Cancel'), // label //
        ), // cancel //
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true), // confirm //
          child: const Text('Delete'), // label //
        ), // delete //
      ], // actions //
    ), // dialog //
  );

  if (confirmed != true) return; // stop //
  if (!context.mounted) return; // 👈 προσθήκη
  Navigator.pop(context, ActivityDetailsAction.delete); // return action //
},

                  ), // btn //
                ), // expanded //
              ], // children //
            ), // row //
          ], // children //
        ), // column //
      ), // scroll //
    ); // safe //
  }
}
