import 'package:travel_ai_app/core/models/expense.dart';
import 'package:travel_ai_app/core/models/trip.dart';


/// Συμβόλαιο για αποθήκευση & ανάκτηση εξόδων.
abstract class ExpenseRepository {
  /// Επιστρέφει όλα τα expenses για ένα συγκεκριμένο trip.
  Future<List<Expense>> getExpensesForTrip(Trip trip);

  /// Προσθέτει ένα νέο expense σε ένα trip.
  Future<void> addExpense({
    required Trip trip,
    required Expense expense,
  });



  /// Διαγράφει ένα expense.
  Future<void> deleteExpense(String expenseId);

  /// ✅ Update υπάρχοντος expense (edit) με βάση το ίδιο id.
  Future<void> updateExpense(Expense expense);

  /// Επιστρέφει το συνολικό ποσό εξόδων για ένα trip.
  Future<double> getTotalForTrip(Trip trip);

  /// Totals ανά κατηγορία για συγκεκριμένο trip.
  Future<Map<String, double>> getTotalsByCategoryForTrip(Trip trip);

  /// ✅ Totals ανά ημέρα (key: yyyy-MM-dd) για συγκεκριμένο trip.
  Future<Map<String, double>> getTotalsByDayForTrip(Trip trip);
}
