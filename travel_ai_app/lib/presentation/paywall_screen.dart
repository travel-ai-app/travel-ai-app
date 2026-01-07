import 'package:flutter/material.dart'; // material //

class PaywallScreen extends StatelessWidget { // paywall //
  const PaywallScreen({super.key}); // ctor //

  @override
  Widget build(BuildContext context) { // build //
    return Scaffold( // scaffold //
      appBar: AppBar( // app bar //
        title: const Text('Travely Pro'), // title //
      ), // end app bar //
      body: Padding( // padding //
        padding: const EdgeInsets.all(16), // spacing //
        child: Column( // column //
          crossAxisAlignment: CrossAxisAlignment.start, // left //
          children: [ // children //
            const Text( // headline //
              'Upgrade to Travely Pro', // text //
              style: TextStyle( // style //
                fontSize: 22, // size //
                fontWeight: FontWeight.bold, // weight //
              ), // end style //
            ), // end headline //
            const SizedBox(height: 8), // spacer //
            const Text( // subtitle //
              'More flexibility for longer and multiple trips.', // text //
              style: TextStyle(fontSize: 16), // style //
            ), // end subtitle //
            const SizedBox(height: 20), // spacer //

            const Text( // section //
              'What you get', // text //
              style: TextStyle( // style //
                fontSize: 18, // size //
                fontWeight: FontWeight.w600, // weight //
              ), // end style //
            ), // end section //
            const SizedBox(height: 12), // spacer //
            const Text('• Unlimited trips'), // bullet //
            const Text('• Longer journeys'), // bullet //
            const Text('• Future AI insights'), // bullet //
            const SizedBox(height: 24), // spacer //

            const Text( // section //
              'Choose a plan', // text //
              style: TextStyle( // style //
                fontSize: 18, // size //
                fontWeight: FontWeight.w600, // weight //
              ), // end style //
            ), // end section //
            const SizedBox(height: 12), // spacer //

            Card( // monthly card //
              child: Padding( // padding //
                padding: const EdgeInsets.all(16), // insets //
                child: Row( // row //
                  children: [ // children //
                    const Expanded( // left //
                      child: Column( // column //
                        crossAxisAlignment: CrossAxisAlignment.start, // left //
                        children: [ // children //
                          Text( // title //
                            'Monthly', // text //
                            style: TextStyle( // style //
                              fontSize: 16, // size //
                              fontWeight: FontWeight.w600, // weight //
                            ), // end style //
                          ), // end title //
                          SizedBox(height: 4), // spacer //
                          Text('Cancel anytime'), // helper //
                        ], // end children //
                      ), // end column //
                    ), // end expanded //
                    const Text( // price placeholder //
                      '—', // placeholder //
                      style: TextStyle( // style //
                        fontSize: 18, // size //
                        fontWeight: FontWeight.bold, // weight //
                      ), // end style //
                    ), // end price //
                  ], // end children //
                ), // end row //
              ), // end padding //
            ), // end monthly //

            Card( // yearly card //
              child: Padding( // padding //
                padding: const EdgeInsets.all(16), // insets //
                child: Row( // row //
                  children: [ // children //
                    const Expanded( // left //
                      child: Column( // column //
                        crossAxisAlignment: CrossAxisAlignment.start, // left //
                        children: [ // children //
                          Text( // title //
                            'Yearly', // text //
                            style: TextStyle( // style //
                              fontSize: 16, // size //
                              fontWeight: FontWeight.w600, // weight //
                            ), // end style //
                          ), // end title //
                          SizedBox(height: 4), // spacer //
                          Text('Best value'), // helper //
                        ], // end children //
                      ), // end column //
                    ), // end expanded //
                    const Text( // price placeholder //
                      '—', // placeholder //
                      style: TextStyle( // style //
                        fontSize: 18, // size //
                        fontWeight: FontWeight.bold, // weight //
                      ), // end style //
                    ), // end price //
                  ], // end children //
                ), // end row //
              ), // end padding //
            ), // end yearly //

            const Spacer(), // push button down //

SizedBox( // button wrapper //
  width: double.infinity, // full width //
  child: ElevatedButton( // primary //
    onPressed: () { // tap //
      // TODO(v2): connect to billing flow // placeholder //
    }, // end tap //
    child: const Text('Continue'), // label //
  ), // end button //
), // end wrapper //
const SizedBox(height: 8), // spacer //
const Text( // small print //
  'This is a preview screen. No purchases or charges are available in this version.', // text //
  style: TextStyle(fontSize: 12), // style //
  textAlign: TextAlign.center, // center //
), // end small print //
Center( // restore //
  child: TextButton( // button //
    onPressed: null, // disabled until billing //
    child: const Text('Restore purchases (coming soon)'), // label //
  ), // end button //
), // end restore //
Center( // maybe later //
  child: TextButton( // secondary //
    onPressed: () => Navigator.of(context).pop(), // back //
    child: const Text('Maybe later'), // label //
  ), // end secondary //
), // end center //

          ], // end children //
        ), // end column //
      ), // end padding //
    ); // end scaffold //
  } // end build //
} // end PaywallScreen //
