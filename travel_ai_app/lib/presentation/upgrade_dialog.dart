import 'package:flutter/material.dart'; // ui //
import 'package:travel_ai_app/core/monetization/monetization_gate.dart'; // GateResult //


enum UpgradeReason { // reasons //
  tripLimit, // 2nd trip blocked //
  dayLimit, // > 5 days blocked //
} // end enum //


Future<void> showUpgradeDialog( // dialog helper //
  BuildContext context, { // ctx //
  required UpgradeReason reason, // why //
}) {
  final bool isTripLimit = reason == UpgradeReason.tripLimit; // flag //

  final String title = isTripLimit // pick title //
      ? 'You’re using Travely Free' // trip title //
      : 'You’re using Travely Free'; // day title //

  final String subtitle = isTripLimit // pick subtitle //
      ? 'Free includes 1 active trip at a time.' // trip subtitle //
      : 'Free includes trips up to 5 days.'; // day subtitle //

  final List<String> freeBullets = isTripLimit // free bullets //
      ? <String>[ // list //
          '1 active trip', // free trips //
          'Up to 5 days per trip', // free days //
        ] // end list //
      : <String>[ // list //
          'Up to 5 days per trip', // free days //
          '1 active trip', // free trips //
        ]; // end list //

  final List<String> proBullets = <String>[ // pro bullets //
    'Unlimited trips', // pro trips //
    'Longer journeys', // pro days //
    'Future: AI trip insights', // future feature mention //
  ]; // end list //

  String bulletsText(List<String> items) { // helper //
    return items.map((e) => '• $e').join('\n'); // bullet join //
  } // end helper //

  final String body = // body text //
      '$subtitle\n\n' // intro //
      'Travely Free:\n${bulletsText(freeBullets)}\n\n' // free section //
      'Travely Pro:\n${bulletsText(proBullets)}'; // pro section //

  return showDialog<void>( // show dialog //
    context: context, // ctx //
    builder: (_) => AlertDialog( // dialog //
      title: Text(title), // title //
      content: Text(body), // body //
      actions: [ // actions //
        TextButton( // secondary //
          onPressed: () => Navigator.of(context).pop(), // close //
          child: const Text('Maybe later'), // label //
        ), // end secondary //
        ElevatedButton( // primary //
          onPressed: () { // tap //
            Navigator.of(context).pop(); // close //
            // TODO(v2): open paywall screen here // placeholder //
          }, // end tap //
          child: const Text('See Pro options'), // label //
        ), // end primary //
      ], // end actions //
    ), // end AlertDialog //
  ); // end showDialog //
} // end showUpgradeDialog //

Future<bool> ensureAllowedOrShowUpgrade({ // central defensive check //
  required BuildContext context, // ctx //
  required GateResult gate, // gate result //
}) async {
  if (gate == GateResult.allowed) { // allowed //
    return true; // proceed //
  } // end allowed //

  if (!context.mounted) { // safety //
    return false; // stop //
  } // end safety //

  final UpgradeReason reason = // map gate -> reason //
      gate == GateResult.blockedDaysLimit // days //
          ? UpgradeReason.dayLimit // map //
          : UpgradeReason.tripLimit; // default //

  await showUpgradeDialog( // show dialog //
    context, // ctx //
    reason: reason, // reason //
  ); // end dialog //

  return false; // stop //
} // end ensureAllowedOrShowUpgrade //

