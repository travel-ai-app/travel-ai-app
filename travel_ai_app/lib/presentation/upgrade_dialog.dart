import 'package:flutter/material.dart'; // ui //

enum UpgradeReason { // reasons //
  tripLimit, // 2nd trip blocked //
  dayLimit, // > 5 days blocked //
} // end enum //

Future<void> showUpgradeDialog( // dialog helper //
  BuildContext context, { // ctx //
  required UpgradeReason reason, // why //
}) {
  final String title = reason == UpgradeReason.tripLimit // pick title //
      ? 'Keep all your trips together' // trip title //
      : 'Plan longer journeys'; // day title //

  final String body = reason == UpgradeReason.tripLimit // pick body //
      ? 'Travely Free supports 1 active trip.\n\nGo Pro to create unlimited trips and never lose your plans.' // trip body //
      : 'The free version of Travely supports trips up to 5 days.\n\nUpgrade to plan longer trips and keep everything in one place.'; // day body //

  return showDialog<void>( // show dialog //
    context: context, // ctx //
    builder: (_) => AlertDialog( // dialog //
      title: Text(title), // title //
      content: Text(body), // body //
      actions: [ // actions //
        TextButton( // not now //
          onPressed: () => Navigator.of(context).pop(), // close //
          child: const Text('Not now'), // label //
        ), // end not now //
        ElevatedButton( // upgrade //
          onPressed: () { // tap //
            Navigator.of(context).pop(); // close //
            // TODO(v2): open paywall screen here // placeholder //
          }, // end tap //
          child: const Text('Upgrade to Pro'), // label //
        ), // end upgrade //
      ], // end actions //
    ), // end AlertDialog //
  ); // end showDialog //
} // end showUpgradeDialog //
