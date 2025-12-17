/// Κεντρικό σημείο για όλα τα κείμενα (labels, τίτλοι κ.λπ.) της εφαρμογής.
/// Προς το παρόν είναι απλά στα Αγγλικά, αλλά αργότερα μπορεί να αντικατασταθεί
/// από πραγματικό localization (AppLocalizations / .arb αρχεία κ.λπ.).
class AppStrings {
  // Γενικά
  static const appTitle = 'Travel AI App'; // Τίτλος εφαρμογής
  static const ok = 'OK'; // Γενικό κουμπί OK
  static const cancel = 'Cancel'; // Ακύρωση
  static const save = 'Save'; // Αποθήκευση
  static const delete = 'Delete'; // Διαγραφή
  static const edit = 'Edit'; // Επεξεργασία

  // Home / Trips
  static const myTripsTitle = 'My Trips'; // Τίτλος λίστας ταξιδιών
  static const addTrip = 'Add Trip'; // Κουμπί "Νέο ταξίδι"
  static const noTripsYet = 'You have no trips yet.'; // Empty state
  static const createFirstTrip = 'Create your first trip to get started.'; // Περιγραφή empty state

  // Trip details / overview
  static const tripOverview = 'Trip overview'; // Επισκόπηση ταξιδιού
  static const itineraryTab = 'Itinerary'; // Tab για πρόγραμμα
  static const expensesTab = 'Expenses'; // Tab για έξοδα
  static const summaryTab = 'Summary'; // Tab για συνοπτικά

  // Itinerary
  static const emptyItineraryTitle = 'No itinerary yet'; // Empty state τίτλος
  static const emptyItineraryDescription =
      'Ask the AI to suggest an itinerary or add your own activities.'; // Περιγραφή

  static const addActivity = 'Add activity'; // Κουμπί προσθήκης activity

  // Expenses
  static const emptyExpensesTitle = 'No expenses yet'; // Empty state για έξοδα
  static const emptyExpensesDescription =
      'Track your travel costs to stay on top of your budget.'; // Περιγραφή

  static const addExpense = 'Add expense'; // Κουμπί προσθήκης εξόδου

  // AI related
  static const aiSuggestionsTitle = 'AI suggestions'; // Τίτλος section για AI
  static const whatShouldIDoNow = 'What should I do now?'; // Κουμπί/ερώτηση
  static const generatingSuggestions = 'Generating suggestions...'; // Μήνυμα κατά τη διάρκεια
  static const noSuggestionsYet = 'No suggestions yet.'; // Empty state

  // Day parts (DayPart enum labels)
  static const morning = 'Morning'; // Πρωί
  static const afternoon = 'Afternoon'; // Απόγευμα
  static const evening = 'Evening'; // Βράδυ
}
