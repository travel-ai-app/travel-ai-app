import 'dart:convert'; // jsonEncode/jsonDecode //
import 'package:shared_preferences/shared_preferences.dart'; // local storage //

import 'package:travel_ai_app/core/models/expense.dart'; // Expense //
import 'package:travel_ai_app/core/models/trip.dart'; // Trip //

import 'expense_repository.dart'; // contract //

class InMemoryExpenseRepository implements ExpenseRepository { // repo //
  static final InMemoryExpenseRepository _instance = InMemoryExpenseRepository._internal(); // singleton //
  factory InMemoryExpenseRepository() => _instance; // accessor //
  InMemoryExpenseRepository._internal(); // private ctor //

  static const String _storageKey = 'expenses_v1'; // prefs key //

  final List<Expense> _expenses = <Expense>[]; // in-memory //
  bool _loaded = false; // loaded flag //

  Future<void> _ensureLoaded() async { // ensure //
    if (_loaded) return; // already loaded //
    await loadFromStorage(); // load once //
  } // end //

  /// Φόρτωση expenses από SharedPreferences //
  Future<void> loadFromStorage() async { // load //
    final prefs = await SharedPreferences.getInstance(); // prefs //
    final raw = prefs.getString(_storageKey); // read json //

    _expenses.clear(); // reset //

    if (raw != null && raw.trim().isNotEmpty) { // has data //
      final decoded = jsonDecode(raw); // decode //

      if (decoded is List) { // list //
        for (final item in decoded) { // loop //
          if (item is Map<String, dynamic>) { // typed map //
            _expenses.add(Expense.fromJson(item)); // add //
          } else if (item is Map) { // untyped map //
            _expenses.add(Expense.fromJson(Map<String, dynamic>.from(item))); // cast + add //
          } // end if //
        } // end loop //
      } // end if //
    } // end if //

    _loaded = true; // mark loaded //
  } // end //

  /// ✅ ΠΡΑΓΜΑΤΙΚΟ persist στο SharedPreferences (ΑΥΤΟ ΕΛΕΙΠΕ / ΗΤΑΝ ΛΑΘΟΣ) //
  Future<void> _persistToStorage() async { // persist //
    final prefs = await SharedPreferences.getInstance(); // prefs //
    final list = _expenses.map((e) => e.toJson()).toList(); // to json list //
    await prefs.setString(_storageKey, jsonEncode(list)); // save //
  } // end //

  /// Seed ΜΟΝΟ αν δεν υπάρχει ήδη αποθηκευμένο JSON //
  Future<void> seedIfEmpty(List<Expense> seed) async { // seed //
    final prefs = await SharedPreferences.getInstance(); // prefs //
    final raw = prefs.getString(_storageKey); // read //

    if (raw != null && raw.trim().isNotEmpty) { // already stored //
      return; // do nothing //
    } // end if //

    _expenses // list //
      ..clear() // clear //
      ..addAll(seed); // add seed //

    _loaded = true; // mark loaded //
    await _persistToStorage(); // ✅ persist seed //
  } // end //

  // ============================== //
  // ExpenseRepository implementation //
  // ============================== //

  @override
  Future<List<Expense>> getExpensesForTrip(Trip trip) async { // get list //
    await _ensureLoaded(); // ensure //

    final list = _expenses.where((e) => e.tripId == trip.id).toList(); // filter //
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first //

    return list; // return //
  } // end //

  @override
  Future<void> addExpense({ // add //
    required Trip trip, // trip //
    required Expense expense, // expense //
  }) async { // start //
    await _ensureLoaded(); // ensure //

    final fixed = (expense.tripId == trip.id) // correct tripId? //
        ? expense // ok //
        : expense.copyWith(tripId: trip.id); // fix //

    _expenses.add(fixed); // add //
    await _persistToStorage(); // ✅ persist //
  } // end //

  @override
  Future<void> deleteExpense(String expenseId) async { // delete //
    await _ensureLoaded(); // ensure //

    _expenses.removeWhere((e) => e.id == expenseId); // remove //
    await _persistToStorage(); // ✅ persist (ΑΥΤΟ ΚΡΑΤΑΕΙ ΤΟ DELETE ΜΕΤΑ ΑΠΟ RESTART) //
  } // end //

  @override
  Future<void> updateExpense(Expense expense) async { // update //
    await _ensureLoaded(); // ensure //

    final index = _expenses.indexWhere((e) => e.id == expense.id); // find //
    if (index == -1) { // not found //
      _expenses.add(expense); // add fallback //
    } else { // found //
      _expenses[index] = expense; // replace //
    } // end if //

    await _persistToStorage(); // ✅ persist //
  } // end //

  @override
  Future<double> getTotalForTrip(Trip trip) async { // total //
    await _ensureLoaded(); // ensure //

    double sum = 0.0; // sum //
    for (final e in _expenses) { // loop //
      if (e.tripId == trip.id) { // same trip //
        sum += e.amount; // add //
      } // end if //
    } // end loop //
    return sum; // return //
  } // end //

  @override
  Future<Map<String, double>> getTotalsByCategoryForTrip(Trip trip) async { // totals by category //
    await _ensureLoaded(); // ensure //

    final Map<String, double> out = <String, double>{}; // out //

    for (final e in _expenses) { // loop //
      if (e.tripId != trip.id) continue; // skip //
      final key = e.category.trim().isEmpty ? 'Other' : e.category.trim(); // key //
      out[key] = (out[key] ?? 0.0) + e.amount; // add //
    } // end loop //

    return out; // return //
  } // end //

  @override
  Future<Map<String, double>> getTotalsByDayForTrip(Trip trip) async { // totals by day //
    await _ensureLoaded(); // ensure //

    final Map<String, double> out = <String, double>{}; // out //

    for (final e in _expenses) { // loop //
      if (e.tripId != trip.id) continue; // skip //
      final dt = e.dateTime; // date //
      final key = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'; // YYYY-MM-DD //
      out[key] = (out[key] ?? 0.0) + e.amount; // add //
    } // end loop //

    return out; // return //
  } // end //

  // ============================== //
  // Extra helpers //
  // ============================== //

  Future<void> clearAll() async { // clear //
    await _ensureLoaded(); // ensure //
    _expenses.clear(); // clear //
    final prefs = await SharedPreferences.getInstance(); // prefs //
    await prefs.remove(_storageKey); // ✅ remove key completely //
  } // end //
} // end class //
