import 'package:flutter/material.dart'; // UI //

import 'package:travel_ai_app/core/models/trip.dart'; // Trip model //
import 'package:travel_ai_app/core/models/expense.dart'; // Expense model //

import 'package:travel_ai_app/core/data/in_memory_expense_repository.dart'; // repo (storage) //

import 'package:travel_ai_app/features/expenses/expense_details_bottom_sheet.dart'; // bottom sheet //
import 'package:travel_ai_app/features/expenses/demo_expenses_screen.dart'; // expenses screen //
import 'package:travel_ai_app/features/expenses/add_expense_demo_screen.dart'; // add/edit expense //
import 'package:travel_ai_app/features/trip/demo_itinerary_screen.dart'; // itinerary screen //

class DemoTripOverviewScreen extends StatefulWidget { // screen //
  final Trip trip; // ✅ trip passed in //

  const DemoTripOverviewScreen({ // ctor //
    super.key, // key //
    required this.trip, // trip //
  });

  @override
  State<DemoTripOverviewScreen> createState() => _DemoTripOverviewScreenState(); // state //
}

class _DemoTripOverviewScreenState extends State<DemoTripOverviewScreen> { // state //
  final InMemoryExpenseRepository _expenseRepo = InMemoryExpenseRepository(); // repo //

  bool _loading = true; // loading //
  List<Expense> _expenses = <Expense>[]; // list //
  double _totalExpenses = 0.0; // total //

  @override
  void initState() { // init //
    super.initState(); // super //
    _load(); // load //
  } // end init //

  Future<void> _load() async { // load data //
    setState(() => _loading = true); // loading on //

    final Trip trip = widget.trip; // ✅ use passed trip //

    final List<Expense> list = await _expenseRepo.getExpensesForTrip(trip); // load list //
    final double total = await _expenseRepo.getTotalForTrip(trip); // load total //

    if (!mounted) return; // guard //

    setState(() { // set //
      _expenses = list; // set list //
      _totalExpenses = total; // set total //
      _loading = false; // loading off //
    }); // end set //
  } // end load //

  @override
  Widget build(BuildContext context) { // build //
    final Trip trip = widget.trip; // ✅ use passed trip //

    final double baseBudget = (trip.baseBudget ?? 0.0); // budget //
    final double remaining = baseBudget - _totalExpenses; // remaining //
    final bool isOver = baseBudget > 0 ? remaining < 0 : false; // over flag //

    return Scaffold( // scaffold //
      appBar: AppBar( // appbar //
        title: Text(trip.title.isNotEmpty ? trip.title : 'Trip Overview'), // title //
        centerTitle: true, // center //
      ), // end appbar //

      body: _loading // loading //
          ? const Center(child: CircularProgressIndicator()) // spinner //
          : RefreshIndicator( // pull refresh //
              onRefresh: _load, // reload //
              child: Padding( // padding //
                padding: const EdgeInsets.all(16), // padding //
                child: Column( // column //
                  crossAxisAlignment: CrossAxisAlignment.start, // align //
                  children: <Widget>[ // children //

                    // ── Title //
                    Text( // title //
                      trip.title.isNotEmpty ? trip.title : trip.destination, // text //
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // style //
                    ), // end text //
                    const SizedBox(height: 4), // gap //
                    Text( // destination //
                      trip.destination, // text //
                      style: const TextStyle(fontSize: 16, color: Colors.grey), // style //
                    ), // end text //
                    const SizedBox(height: 8), // gap //
                    Text( // dates //
                      _formatTripDates(trip), // text //
                      style: const TextStyle(fontSize: 14), // style //
                    ), // end text //
                    const SizedBox(height: 16), // gap //

                    // ── Buttons //
                    Row( // row //
                      children: <Widget>[ // children //
                        Expanded( // itinerary //
                          child: OutlinedButton( // button //
                            onPressed: () async { // press //
                              await Navigator.of(context).push( // push //
                                MaterialPageRoute<Widget>( // route //
                                  builder: (_) => DemoItineraryScreen(trip: trip), // ✅ pass trip //
                                ), // end route //
                              ); // end push //
                            }, // end onPressed //
                            child: const Text('View itinerary'), // label //
                          ), // end button //
                        ), // end expanded //
                        const SizedBox(width: 8), // gap //
                        Expanded( // expenses //
                          child: OutlinedButton( // button //
                            onPressed: () async { // press //
                              final bool? changed = await Navigator.of(context).push<bool>( // push //
                                MaterialPageRoute<bool>( // route //
                                  builder: (_) => DemoExpensesScreen(trip: trip), // ✅ pass trip //
                                ), // end route //
                              ); // end push //

                              if (changed == true) { // changed //
                                await _load(); // reload //
                              } // end if //
                            }, // end onPressed //
                            child: const Text('View expenses'), // label //
                          ), // end button //
                        ), // end expanded //
                      ], // end children //
                    ), // end row //
                    const SizedBox(height: 16), // gap //

                    // ── Summary //
                    Card( // card //
                      child: Padding( // padding //
                        padding: const EdgeInsets.all(16), // padding //
                        child: Row( // row //
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // space //
                          children: <Widget>[ // children //
                            _buildInfoColumn( // budget //
                              'Budget', // label //
                              baseBudget > 0 ? _formatAmount(baseBudget, trip.currencyCode) : '-', // value //
                            ), // end //
                            _buildInfoColumn( // spent //
                              'Spent', // label //
                              _formatAmount(_totalExpenses, trip.currencyCode), // value //
                            ), // end //
                            _buildInfoColumn( // remaining //
                              isOver ? 'Over budget' : 'Remaining', // label //
                              baseBudget > 0 ? _formatAmount(remaining.abs(), trip.currencyCode) : '-', // value //
                              isWarning: isOver, // warning //
                            ), // end //
                          ], // end children //
                        ), // end row //
                      ), // end padding //
                    ), // end card //

                    const SizedBox(height: 16), // gap //

                    Text( // header //
                      'Recent expenses (${_expenses.length})', // label //
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // style //
                    ), // end text //
                    const SizedBox(height: 8), // gap //

                    Expanded( // list //
                      child: _expenses.isEmpty // empty? //
                          ? _buildEmptyState() // empty //
                          : ListView.builder( // list //
                              itemCount: _expenses.length, // count //
                              itemBuilder: (BuildContext context, int index) { // builder //
                                final Expense expense = _expenses[index]; // item //

                                return InkWell( // tap //
                                  onTap: () async { // tap //
                                    final action = await showModalBottomSheet( // sheet //
                                      context: context, // ctx //
                                      isScrollControlled: true, // scroll //
                                      showDragHandle: true, // handle //
                                      builder: (_) => ExpenseDetailsBottomSheet(expense: expense), // sheet //
                                    ); // end //

                                    if (action == 'delete') { // delete //
                                      await _expenseRepo.deleteExpense(expense.id); // delete //
                                      await _load(); // refresh //
                                      return; // stop //
                                    } // end delete //

                                    if (action == 'edit') { // edit //
                                      final bool? changed = await Navigator.of(context).push<bool>( // push //
                                        MaterialPageRoute<bool>( // route //
                                          builder: (_) => AddExpenseDemoScreen( // screen //
                                            trip: trip, // trip //
                                            existingExpense: expense, // existing //
                                          ), // end //
                                        ), // end route //
                                      ); // end push //

                                      if (changed == true) { // if changed //
                                        await _load(); // refresh //
                                      } // end if //
                                    } // end edit //
                                  }, // end onTap //

                                  child: ListTile( // tile //
                                    leading: const Icon(Icons.payments), // icon //
                                    title: Text( // title //
                                      '${expense.category} · ${expense.amount.toStringAsFixed(0)} ${expense.currencyCode}', // text //
                                    ), // end title //
                                    subtitle: Text(expense.note ?? 'No note'), // subtitle //
                                    trailing: Text( // date //
                                      _formatDate(expense.dateTime), // formatted //
                                      style: const TextStyle(fontSize: 12), // style //
                                    ), // end date //
                                  ), // end tile //
                                ); // end ink //
                              }, // end builder //
                            ), // end list //
                    ), // end expanded //
                  ], // end children //
                ), // end column //
              ), // end padding //
            ), // end refresh //
    ); // end scaffold //
  } // end build //

  Widget _buildEmptyState() { // empty ui //
    return Center( // center //
      child: Padding( // padding //
        padding: const EdgeInsets.all(24.0), // space //
        child: Column( // column //
          mainAxisSize: MainAxisSize.min, // compact //
          children: [ // children //
            Icon(Icons.receipt_long, size: 52, color: Colors.blueGrey[400]), // icon //
            const SizedBox(height: 12), // gap //
            const Text( // title //
              'No expenses yet', // text //
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // style //
              textAlign: TextAlign.center, // align //
            ), // end //
            const SizedBox(height: 6), // gap //
            Text( // subtitle //
              'Add your first expense to start tracking your spending.', // text //
              style: TextStyle(fontSize: 13, color: Colors.grey[700]), // style //
              textAlign: TextAlign.center, // align //
            ), // end //
          ], // end children //
        ), // end column //
      ), // end padding //
    ); // end center //
  } // end //

  Widget _buildInfoColumn( // column //
    String label, // label //
    String value, { // value //
    bool isWarning = false, // warning //
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isWarning ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  static String _formatTripDates(Trip trip) {
    final String start = _formatDate(trip.startDate);
    final String end = _formatDate(trip.endDate);
    return '$start - $end';
  }

  static String _formatAmount(double amount, String currencyCode) {
    return '${amount.toStringAsFixed(0)} $currencyCode';
  }

  static String _formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();
    return '$day/$month/$year';
  }
}
