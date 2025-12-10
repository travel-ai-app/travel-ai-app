import 'package:flutter/material.dart'; // Βασικό Flutter UI
import '../../core/mock/mock_data.dart'; // Demo δεδομένα (TripDays + Activities)
import '../../core/models/trip_day.dart'; // Μοντέλο TripDay
import '../../core/models/activity.dart'; // Μοντέλο Activity

class DemoItineraryScreen extends StatelessWidget { // Οθόνη demo itinerary
  const DemoItineraryScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    final List<TripDay> days = MockData.demoTripDays; // Οι demo μέρες ταξιδιού
    final List<Activity> activities = MockData.demoActivities; // Demo δραστηριότητες

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Itinerary'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (BuildContext context, int index) {
          final TripDay day = days[index];

          // Φιλτράρουμε τις δραστηριότητες που ανήκουν σε αυτή τη μέρα
          final List<Activity> dayActivities = activities
              .where((Activity a) => a.dayId == day.id)
              .toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _formatDate(day.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (day.notes != null && day.notes!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      day.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (dayActivities.isEmpty)
                    const Text(
                      'No activities planned for this day',
                      style: TextStyle(fontSize: 14),
                    )
                  else
                    Column(
                      children: dayActivities.map((Activity act) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on),
                          title: Text(act.title),
                          subtitle: Text(
                            act.description ?? 'No description',
                          ),
                          trailing: act.estimatedCost != null
                              ? Text(
                            '${act.estimatedCost!.toStringAsFixed(0)} ${act.currencyCode}',
                            style: const TextStyle(fontSize: 12),
                          )
                              : null,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    return '$day/$month/$year';
  }
}
