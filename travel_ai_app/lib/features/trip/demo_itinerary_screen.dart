import 'package:flutter/material.dart'; // UI //

import 'package:travel_ai_app/core/models/trip.dart'; // Trip //
import 'package:travel_ai_app/core/models/activity.dart'; // Activity //
import 'package:travel_ai_app/core/models/day_part.dart'; // DayPart //
import 'package:travel_ai_app/core/data/in_memory_activity_repository.dart'; // repo //

class DemoItineraryScreen extends StatefulWidget { // screen //
  final Trip trip; // ✅ trip //

  const DemoItineraryScreen({ // ctor //
    super.key, // key //
    required this.trip, // trip //
  });

  @override
  State<DemoItineraryScreen> createState() => _DemoItineraryScreenState(); // state //
}

class _DemoItineraryScreenState extends State<DemoItineraryScreen> { // state //
  final InMemoryActivityRepository _activityRepo = InMemoryActivityRepository(); // repo //

  bool _loading = true; // loading //
  final Map<String, Map<DayPart, List<Activity>>> _byDay = <String, Map<DayPart, List<Activity>>>{}; // grouped //

  @override
  void initState() { // init //
    super.initState(); // super //
    _load(); // load //
  } // end init //

  Future<void> _load() async { // load //
    setState(() => _loading = true); // on //

    final all = await _activityRepo.getActivitiesForTrip(widget.trip); // fetch //

    final Map<String, Map<DayPart, List<Activity>>> grouped = <String, Map<DayPart, List<Activity>>>{}; // tmp //

    for (final a in all) { // loop //
      final date = a.date; // date //
      if (date == null) continue; // skip //

      final key = _dayKey(date); // yyyy-MM-dd //
      final dayMap = grouped.putIfAbsent(key, () => <DayPart, List<Activity>>{}); // dayMap //
      final list = dayMap.putIfAbsent(a.dayPart, () => <Activity>[]); // list //
      list.add(a); // add //
    } // end loop //

    // sort μέσα στη μέρα //
    for (final dayMap in grouped.values) { // each day //
      for (final part in dayMap.keys) { // each part //
        dayMap[part]!.sort((x, y) => x.title.compareTo(y.title)); // sort by title //
      } // end //
    } // end //

    if (!mounted) return; // guard //

    setState(() { // set //
      _byDay
        ..clear() // clear //
        ..addAll(grouped); // set //
      _loading = false; // off //
    }); // end //
  } // end load //

  @override
  Widget build(BuildContext context) { // build //
    final trip = widget.trip; // trip //
    final start = trip.startDate; // start //
    final end = trip.endDate; // end //
    final int dayCount = end.difference(start).inDays + 1; // days //

    return Scaffold( // scaffold //
      appBar: AppBar( // appbar //
        title: const Text('Itinerary'), // title //
        centerTitle: true, // center //
      ), // end //
      body: _loading // loading? //
          ? const Center(child: CircularProgressIndicator()) // spinner //
          : RefreshIndicator( // refresh //
              onRefresh: _load, // reload //
              child: ListView.builder( // list //
                padding: const EdgeInsets.all(16), // padding //
                itemCount: dayCount, // count //
                itemBuilder: (context, index) { // builder //
                  final date = start.add(Duration(days: index)); // date //
                  final dayKey = _dayKey(date); // key //
                  final label = 'Day ${index + 1} · ${_formatDate(date)}'; // label //

                  return Card( // card //
                    margin: const EdgeInsets.only(bottom: 12), // margin //
                    child: Padding( // padding //
                      padding: const EdgeInsets.all(12), // padding //
                      child: Column( // column //
                        crossAxisAlignment: CrossAxisAlignment.start, // align //
                        children: [ // children //
                          Text( // title //
                            label, // text //
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // style //
                          ), // end //
                          const SizedBox(height: 10), // gap //
                          _section(dayKey, DayPart.morning, 'Morning', Icons.wb_sunny_outlined), // morning //
                          const SizedBox(height: 10), // gap //
                          _section(dayKey, DayPart.afternoon, 'Afternoon', Icons.light_mode_outlined), // afternoon //
                          const SizedBox(height: 10), // gap //
                          _section(dayKey, DayPart.evening, 'Evening', Icons.nightlight_outlined), // evening //
                        ], // end //
                      ), // end //
                    ), // end //
                  ); // end //
                }, // end //
              ), // end //
            ), // end //
    ); // end scaffold //
  } // end build //

  Widget _section(String dayKey, DayPart part, String title, IconData icon) { // section //
    final list = _byDay[dayKey]?[part] ?? <Activity>[]; // list //

    return Column( // column //
      crossAxisAlignment: CrossAxisAlignment.start, // align //
      children: [ // children //
        Row( // row //
          children: [ // children //
            Icon(icon, size: 18), // icon //
            const SizedBox(width: 8), // gap //
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), // title //
          ], // end //
        ), // end row //
        const SizedBox(height: 6), // gap //
        if (list.isEmpty) // empty //
          const Padding( // padding //
            padding: EdgeInsets.only(left: 26.0), // left //
            child: Text('No activities yet', style: TextStyle(fontSize: 13, color: Colors.grey)), // text //
          ) // end //
        else
          Padding( // padding //
            padding: const EdgeInsets.only(left: 26.0), // left //
            child: Column( // column //
              children: list.map((a) { // map //
                final cost = a.estimatedCost; // cost //
                final currency = a.currencyCode ?? ''; // currency //
                final extra = <String>[]; // extra //

                if ((a.category ?? '').trim().isNotEmpty) extra.add(a.category!.trim()); // category //
                if (cost != null && cost > 0) extra.add('${cost.toStringAsFixed(0)} $currency'); // cost //

                return Padding( // padding //
                  padding: const EdgeInsets.only(bottom: 6.0), // bottom //
                  child: Row( // row //
                    crossAxisAlignment: CrossAxisAlignment.start, // align //
                    children: [ // children //
                      const Text('• '), // bullet //
                      Expanded( // expand //
                        child: Column( // column //
                          crossAxisAlignment: CrossAxisAlignment.start, // align //
                          children: [ // children //
                            Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), // title //
                            if ((a.description ?? '').trim().isNotEmpty) // desc //
                              Text(a.description!, style: const TextStyle(fontSize: 13, color: Colors.grey)), // desc //
                            if (extra.isNotEmpty) // extra //
                              Text(extra.join(' • '), style: const TextStyle(fontSize: 12, color: Colors.grey)), // extra //
                          ], // end //
                        ), // end //
                      ), // end //
                    ], // end //
                  ), // end //
                ); // end //
              }).toList(), // end //
            ), // end //
          ), // end //
      ], // end //
    ); // end //
  } // end section //

  static String _dayKey(DateTime d) { // key //
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'; // yyyy-MM-dd //
  } // end //

  static String _formatDate(DateTime d) { // format //
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'; // dd/MM/yyyy //
  } // end //
}
