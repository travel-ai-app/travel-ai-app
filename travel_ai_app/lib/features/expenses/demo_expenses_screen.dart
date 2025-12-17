import 'package:flutter/material.dart'; // Flutter UI //

import '../../core/models/expense.dart'; // Expense model //
import '../../core/models/trip.dart'; // Trip model //
import '../../core/data/in_memory_expense_repository.dart'; // Persistent expense repo //

import 'add_expense_demo_screen.dart'; // Add/Edit expense screen //

class DemoExpensesScreen extends StatefulWidget { // Screen //
  final Trip trip; // Trip //

  const DemoExpensesScreen({ // Ctor //
    super.key, // Key //
    required this.trip, // Trip //
  }); // End ctor //

  @override
  State<DemoExpensesScreen> createState() => _DemoExpensesScreenState(); // Create state //
} // End widget //

class _DemoExpensesScreenState extends State<DemoExpensesScreen> { // State //
  final InMemoryExpenseRepository _expenseRepo = InMemoryExpenseRepository(); // Repo //

  bool _loading = true; // Loading //
  List<Expense> _expenses = <Expense>[]; // Items //
  double _total = 0.0; // Total //

  bool _changed = false; // ✅ Return to caller when true //

  @override
  void initState() { // init //
    super.initState(); // super //
    _loadExpenses(); // load //
  } // end init //

  Future<void> _loadExpenses() async { // load //
    if (!mounted) return; // guard //
    setState(() { // set //
      _loading = true; // loading on //
    }); // end set //

    final List<Expense> list = await _expenseRepo.getExpensesForTrip(widget.trip); // fetch list //
    final double total = await _expenseRepo.getTotalForTrip(widget.trip); // fetch total //

    list.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first //

    if (!mounted) return; // guard //

    setState(() { // set //
      _expenses = list; // set list //
      _total = total; // set total //
      _loading = false; // loading off //
    }); // end set //
  } // end load //

  void _exitWithResult() { // ✅ single exit path //
    Navigator.of(context).pop(_changed); // return changed //
  } // end exit //

  Future<bool> _onWillPop() async { // ✅ system back / gesture back //
    _exitWithResult(); // exit //
    return false; // prevent default pop (we already popped) //
  } // end willpop //

  Future<void> _openAdd() async { // open add //
    final bool? changed = await Navigator.of(context).push<bool>( // push //
      MaterialPageRoute<bool>( // route //
        builder: (_) => AddExpenseDemoScreen( // screen //
          trip: widget.trip, // trip //
        ), // end screen //
      ), // end route //
    ); // end push //

    if (changed == true) { // if changed //
      _changed = true; // mark //
      await _loadExpenses(); // reload //
    } // end if //
  } // end open add //

  Future<void> _openEdit(Expense expense) async { // open edit //
    final bool? changed = await Navigator.of(context).push<bool>( // push //
      MaterialPageRoute<bool>( // route //
        builder: (_) => AddExpenseDemoScreen( // screen //
          trip: widget.trip, // trip //
          existingExpense: expense, // edit mode //
        ), // end screen //
      ), // end route //
    ); // end push //

    if (changed == true) { // if changed //
      _changed = true; // mark //
      await _loadExpenses(); // reload //
    } // end if //
  } // end open edit //

  Future<void> _deleteExpense(Expense expense) async { // delete //
    await _expenseRepo.deleteExpense(expense.id); // delete //
    _changed = true; // mark //
    await _loadExpenses(); // reload //
  } // end delete //

  @override
  Widget build(BuildContext context) { // build //
    final Trip trip = widget.trip; // trip //

    final double baseBudget = _tryGetBaseBudget(trip); // safe budget //
    final double remaining = baseBudget > 0 ? (baseBudget - _total) : 0.0; // remaining //

    return WillPopScope( // ✅ intercept system back //
      onWillPop: _onWillPop, // handler //
      child: Scaffold( // scaffold //
        appBar: AppBar( // appbar //
          title: Text( // title //
            '${trip.title.isNotEmpty ? trip.title : trip.destination} · Expenses', // text //
          ), // end title //
          centerTitle: true, // center //
          leading: BackButton( // ✅ appbar back returns result too //
            onPressed: _exitWithResult, // exit //
          ), // end back button //
        ), // end appbar //

        body: RefreshIndicator( // pull to refresh //
          onRefresh: _loadExpenses, // refresh //
          child: _loading // if loading //
              ? const Center(child: CircularProgressIndicator()) // spinner //
              : ListView.builder( // list //
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // padding //
                  itemCount: _expenses.length + 1, // + summary //
                  itemBuilder: (BuildContext context, int index) { // builder //
                    if (index == 0) { // summary card //
                      return _buildSummaryCard( // card //
                        baseBudget, // budget //
                        _total, // spent //
                        remaining, // remaining //
                        trip.currencyCode, // currency //
                      ); // end //
                    } // end summary //

                    final Expense expense = _expenses[index - 1]; // item //

                    return Dismissible( // swipe delete //
                      key: ValueKey<String>(expense.id), // key //
                      direction: DismissDirection.endToStart, // direction //
                      background: Container( // background //
                        alignment: Alignment.centerRight, // align //
                        padding: const EdgeInsets.symmetric(horizontal: 16), // padding //
                        decoration: BoxDecoration( // decoration //
                          color: Colors.red.withOpacity(0.12), // color //
                          borderRadius: BorderRadius.circular(12), // radius //
                        ), // end decoration //
                        child: const Icon(Icons.delete, color: Colors.red), // icon //
                      ), // end background //
                      confirmDismiss: (_) async { // confirm //
                        final bool? ok = await showDialog<bool>( // dialog //
                          context: context, // context //
                          builder: (_) { // builder //
                            return AlertDialog( // dialog //
                              title: const Text('Delete expense?'), // title //
                              content: const Text('This action cannot be undone.'), // content //
                              actions: [ // actions //
                                TextButton( // cancel //
                                  onPressed: () => Navigator.of(context).pop(false), // pop false //
                                  child: const Text('Cancel'), // text //
                                ), // end //
                                TextButton( // delete //
                                  onPressed: () => Navigator.of(context).pop(true), // pop true //
                                  child: const Text('Delete'), // text //
                                ), // end //
                              ], // end actions //
                            ); // end dialog //
                          }, // end builder //
                        ); // end showDialog //
                        return ok ?? false; // return //
                      }, // end confirm //
                      onDismissed: (_) async { // dismissed //
                        await _deleteExpense(expense); // delete //
                      }, // end dismissed //
                      child: Card( // card //
                        margin: const EdgeInsets.symmetric(vertical: 6), // margin //
                        child: ListTile( // tile //
                          onTap: () => _openEdit(expense), // tap edit //
                          leading: const Icon(Icons.payments), // icon //
                          title: Text( // title //
                            '${expense.category} · ${expense.amount.toStringAsFixed(0)} ${expense.currencyCode}', // text //
                          ), // end title //
                          subtitle: Text(_buildSubtitle(expense)), // subtitle //
                          trailing: Text( // trailing //
                            _formatDate(expense.dateTime), // date //
                            style: const TextStyle(fontSize: 12), // style //
                          ), // end trailing //
                        ), // end tile //
                      ), // end card //
                    ); // end dismissible //
                  }, // end itemBuilder //
                ), // end list //
        ), // end body //

        floatingActionButton: FloatingActionButton( // fab //
          onPressed: _openAdd, // add //
          child: const Icon(Icons.add), // icon //
        ), // end fab //
      ), // end scaffold //
    ); // end WillPopScope //
  } // end build //

  String _buildSubtitle(Expense expense) { // subtitle //
    final String payment = (expense.paymentMethod ?? '').trim(); // payment //
    final String note = (expense.note ?? '').trim(); // note //

    final String paymentText = payment.isEmpty ? 'Payment: -' : 'Payment: $payment'; // payment text //
    final String noteText = note.isEmpty ? 'No note' : note; // note text //

    return '$paymentText\n$noteText'; // return //
  } // end subtitle //

  Widget _buildSummaryCard( // summary card //
    double baseBudget, // budget //
    double totalExpenses, // spent //
    double remaining, // remaining //
    String currencyCode, // currency //
  ) { // start //
    final bool hasBudget = baseBudget > 0; // has budget //
    final bool isOver = hasBudget ? remaining < 0 : false; // over //
    final String remainingLabel = isOver ? 'Over budget' : 'Remaining'; // label //
    final String remainingValue = hasBudget ? _formatAmount(remaining.abs(), currencyCode) : '-'; // value //

    return Card( // card //
      margin: const EdgeInsets.symmetric(vertical: 8), // margin //
      child: Padding( // padding //
        padding: const EdgeInsets.all(16), // padding //
        child: Column( // column //
          crossAxisAlignment: CrossAxisAlignment.start, // align //
          children: <Widget>[ // children //
            const Text( // title //
              'Trip budget summary', // text //
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // style //
            ), // end title //
            const SizedBox(height: 8), // gap //
            Row( // row //
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // space //
              children: <Widget>[ // children //
                _buildSummaryItem('Budget', hasBudget ? _formatAmount(baseBudget, currencyCode) : '-'), // budget //
                _buildSummaryItem('Spent', _formatAmount(totalExpenses, currencyCode)), // spent //
                _buildSummaryItem(remainingLabel, remainingValue, isWarning: isOver), // remaining //
              ], // end children //
            ), // end row //
          ], // end children //
        ), // end column //
      ), // end padding //
    ); // end card //
  } // end summary card //

  Widget _buildSummaryItem( // summary item //
    String label, // label //
    String value, { // value //
    bool isWarning = false, // warning //
  }) { // start //
    return Column( // column //
      crossAxisAlignment: CrossAxisAlignment.start, // align //
      children: <Widget>[ // children //
        Text( // label //
          label, // text //
          style: const TextStyle(fontSize: 12, color: Colors.grey), // style //
        ), // end label //
        const SizedBox(height: 4), // gap //
        Text( // value //
          value, // text //
          style: TextStyle( // style //
            fontSize: 14, // size //
            fontWeight: FontWeight.w600, // weight //
            color: isWarning ? Colors.red : Colors.black, // color //
          ), // end style //
        ), // end value //
      ], // end children //
    ); // end column //
  } // end item //

  double _tryGetBaseBudget(Trip trip) { // safe budget //
    try { // try //
      final dynamic t = trip; // dynamic //
      final dynamic v = t.baseBudget; // attempt //
      if (v is num) return v.toDouble(); // num -> double //
      return 0.0; // fallback //
    } catch (_) { // catch //
      return 0.0; // fallback //
    } // end //
  } // end helper //

  static String _formatAmount(double amount, String currencyCode) { // format //
    return '${amount.toStringAsFixed(0)} $currencyCode'; // return //
  } // end format //

  static String _formatDate(DateTime dateTime) { // format date //
    final String day = dateTime.day.toString().padLeft(2, '0'); // day //
    final String month = dateTime.month.toString().padLeft(2, '0'); // month //
    final String year = dateTime.year.toString(); // year //
    final String hour = dateTime.hour.toString().padLeft(2, '0'); // hour //
    final String minute = dateTime.minute.toString().padLeft(2, '0'); // minute //
    return '$day/$month/$year $hour:$minute'; // return //
  } // end format //
} // end state //
