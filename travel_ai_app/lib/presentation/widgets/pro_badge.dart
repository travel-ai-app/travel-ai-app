import 'package:flutter/material.dart'; // material //

class ProBadge extends StatelessWidget { // small pro indicator //
  const ProBadge({super.key}); // ctor //

  @override
  Widget build(BuildContext context) { // build //
    return Container( // badge container //
      padding: const EdgeInsets.symmetric( // padding //
        horizontal: 8, // x //
        vertical: 4, // y //
      ), // end padding //
      decoration: BoxDecoration( // decoration //
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // subtle //
        borderRadius: BorderRadius.circular(12), // rounded //
      ), // end decoration //
      child: Text( // label //
        'PRO', // text //
        style: TextStyle( // style //
          fontSize: 12, // size //
          fontWeight: FontWeight.w600, // weight //
          color: Theme.of(context).colorScheme.primary, // color //
        ), // end style //
      ), // end text //
    ); // end container //
  } // end build //
} // end ProBadge //
