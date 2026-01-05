import 'package:flutter/material.dart'; // UI //

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key}); // ctor //

  @override
  Widget build(BuildContext context) {
    return Scaffold( // page //
      appBar: AppBar( // top bar //
        title: const Text('About & Legal'), // title //
      ), // end appbar //
      body: ListView( // scroll //
        padding: const EdgeInsets.all(16), // padding //
        children: [ // children //
          const Text( // app name //
            'Travely', // text //
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), // style //
          ), // end text //
          const SizedBox(height: 6), // gap //
          Text( // subtitle //
            'Travel companion – calm, helpful, and private.', // text //
            style: TextStyle(color: Colors.grey[700]), // style //
          ), // end text //
          const SizedBox(height: 16), // gap //

          _LegalTile( // privacy tile //
            title: 'Privacy Policy', // title //
            subtitle: 'How Travely handles data (v1).', // subtitle //
            onTap: () => Navigator.of(context).push( // navigate //
              MaterialPageRoute<void>( // route //
                builder: (_) => const _LegalDocScreen( // doc page //
                  title: 'Privacy Policy', // doc title //
                  body: _privacyPolicyText, // doc body //
                ), // end doc //
              ), // end route //
            ), // end push //
          ), // end tile //

          _LegalTile( // terms tile //
            title: 'Terms of Use', // title //
            subtitle: 'Rules and limitations (v1).', // subtitle //
            onTap: () => Navigator.of(context).push( // navigate //
              MaterialPageRoute<void>( // route //
                builder: (_) => const _LegalDocScreen( // doc page //
                  title: 'Terms of Use', // doc title //
                  body: _termsText, // doc body //
                ), // end doc //
              ), // end route //
            ), // end push //
          ), // end tile //

          _LegalTile( // disclaimer tile //
            title: 'Disclaimer (Travel & AI)', // title //
            subtitle: 'Important notes about suggestions.', // subtitle //
            onTap: () => Navigator.of(context).push( // navigate //
              MaterialPageRoute<void>( // route //
                builder: (_) => const _LegalDocScreen( // doc page //
                  title: 'Disclaimer', // doc title //
                  body: _disclaimerText, // doc body //
                ), // end doc //
              ), // end route //
            ), // end push //
          ), // end tile //

          const SizedBox(height: 24), // gap //
          const Divider(), // divider //
          const SizedBox(height: 12), // gap //

          Text( // signature //
            'Made by PandemoniuM Productions', // text //
            textAlign: TextAlign.center, // align //
            style: TextStyle(color: Colors.grey[700]), // style //
          ), // end text //
          const SizedBox(height: 8), // gap //
          Text( // contact //
            'Contact: travelaipp@gmail.com', // text //
            textAlign: TextAlign.center, // align //
            style: TextStyle(color: Colors.grey[700]), // style //
          ), // end text //
        ], // end children //
      ), // end list //
    ); // end scaffold //
  } // end build //
} // end screen //

class _LegalTile extends StatelessWidget {
  final String title; // title //
  final String subtitle; // subtitle //
  final VoidCallback onTap; // tap //

  const _LegalTile({ // ctor //
    required this.title, // req //
    required this.subtitle, // req //
    required this.onTap, // req //
  }); // end ctor //

  @override
  Widget build(BuildContext context) {
    return Card( // card //
      margin: const EdgeInsets.only(bottom: 10), // spacing //
      child: ListTile( // list tile //
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), // title //
        subtitle: Text(subtitle), // subtitle //
        trailing: const Icon(Icons.chevron_right), // icon //
        onTap: onTap, // tap //
      ), // end tile //
    ); // end card //
  } // end build //
} // end tile //

class _LegalDocScreen extends StatelessWidget {
  final String title; // title //
  final String body; // body //

  const _LegalDocScreen({ // ctor //
    required this.title, // req //
    required this.body, // req //
  }); // end ctor //

  @override
  Widget build(BuildContext context) {
    return Scaffold( // page //
      appBar: AppBar(title: Text(title)), // top bar //
      body: SingleChildScrollView( // scroll //
        padding: const EdgeInsets.all(16), // padding //
        child: Text( // content //
          body, // text //
          style: const TextStyle(height: 1.35), // readability //
        ), // end text //
      ), // end scroll //
    ); // end scaffold //
  } // end build //
} // end doc //

const String _privacyPolicyText = '''
Privacy Policy — Travely (v1)
Last updated: January 2026

Travely (“the App”) respects your privacy. This Privacy Policy explains how information is handled when you use the App.

1. Information We Do Not Collect
Travely does not collect, store, or process:
- Personal identification information (name, email, phone number)
- Account credentials
- Payment or billing information
- Real-time location data
- Contact lists
- Device identifiers for tracking
- Analytics or advertising identifiers

2. Local Data Storage
All data you create in the App (such as trips, itineraries, activities, and expenses) is stored locally on your device only.
- No data is uploaded to servers
- No cloud synchronization is performed
- No data is shared with third parties

If you delete the App, all locally stored data is permanently removed.

3. Third-Party Services
Travely does not integrate third-party analytics, advertising, or tracking services in v1.

4. Artificial Intelligence Features
Any AI-powered features provide suggestions and insights. Outputs are not guaranteed to be accurate or complete.

5. Children’s Privacy
Travely is not intended for children under the age of 13. We do not knowingly collect any personal data from children.

6. Changes to This Policy
This Privacy Policy may be updated in future versions of the App. Any changes will be reflected within the App.

7. Contact
travelaipp@gmail.com
''';

const String _termsText = '''
Terms of Use — Travely (v1)
Last updated: January 2026

By using Travely, you agree to the following Terms of Use.

1. Purpose of the App
Travely is a travel companion tool designed to help users organize trips, itineraries, and expenses. It is intended for informational and organizational purposes only.

2. No Professional Advice
Travely does not provide financial advice, travel guarantees, or professional planning services.

3. User Responsibility
You acknowledge that travel decisions are made at your own discretion and you are responsible for verifying information independently.

4. Limitation of Liability
Travely and its creators shall not be held liable for financial loss, travel disruptions, or decisions made based on App content. Use of the App is at your own risk.

5. Intellectual Property
All content, branding, and software associated with Travely are the property of PandemoniuM Productions, unless otherwise stated.

6. Modifications
These Terms may be updated in future versions. Continued use of the App constitutes acceptance of any changes.
''';

const String _disclaimerText = '''
Disclaimer — Travel & AI (v1)

Travely may include automated or AI-assisted logic to provide suggestions, summaries, or insights.

- Outputs are not guaranteed to be accurate, complete, or up to date.
- AI features do not replace human judgment.
- Travely does not guarantee travel outcomes, costs, or availability.
- Users must independently verify all information before acting on it.

Travely is a supportive companion, not a decision-maker.
''';
