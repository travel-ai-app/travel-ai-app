class Expense { // Κλάση για έξοδο ταξιδιού
  final String id; // Μοναδικό ID εξόδου
  final String tripId; // Σε ποιο ταξίδι ανήκει
  final DateTime dateTime; // Ημερομηνία και ώρα του εξόδου
  final double amount; // Ποσό εξόδου
  final String currencyCode; // Νόμισμα (π.χ. "EUR", "THB")
  final String category; // Κατηγορία (π.χ. "Food", "Transport", "Hotel")
  final String? paymentMethod; // Μέθοδος πληρωμής (π.χ. "Cash", "Card")
  final String? note; // Προαιρετική σημείωση

  Expense({ // Constructor
    required this.id, // Απαιτείται id
    required this.tripId, // Απαιτείται tripId
    required this.dateTime, // Απαιτείται dateTime
    required this.amount, // Απαιτείται amount
    required this.currencyCode, // Απαιτείται currencyCode
    required this.category, // Απαιτείται category
    this.paymentMethod, // Προαιρετικό paymentMethod
    this.note, // Προαιρετική note
  }); // Τέλος constructor

  Expense copyWith({ // Δημιουργία νέου Expense με αλλαγές
    String? id, // Νέο id
    String? tripId, // Νέο tripId
    DateTime? dateTime, // Νέο dateTime
    double? amount, // Νέο amount
    String? currencyCode, // Νέο currencyCode
    String? category, // Νέα category
    String? paymentMethod, // Νέο paymentMethod
    String? note, // Νέα note
  }) { // Άνοιγμα copyWith
    return Expense( // Επιστρέφει νέο Expense
      id: id ?? this.id, // id
      tripId: tripId ?? this.tripId, // tripId
      dateTime: dateTime ?? this.dateTime, // dateTime
      amount: amount ?? this.amount, // amount
      currencyCode: currencyCode ?? this.currencyCode, // currencyCode
      category: category ?? this.category, // category
      paymentMethod: paymentMethod ?? this.paymentMethod, // paymentMethod
      note: note ?? this.note, // note
    ); // Τέλος Expense(...)
  } // Τέλος copyWith

  factory Expense.fromJson(Map<String, dynamic> json) { // Factory από JSON
    return Expense( // Δημιουργία Expense
      id: json['id'] as String, // id
      tripId: json['tripId'] as String, // tripId
      dateTime: DateTime.parse(json['dateTime'] as String), // dateTime σε DateTime
      amount: (json['amount'] as num).toDouble(), // amount σε double
      currencyCode: json['currencyCode'] as String, // currencyCode
      category: json['category'] as String, // category
      paymentMethod: json['paymentMethod'] as String?, // paymentMethod
      note: json['note'] as String?, // note
    ); // Τέλος Expense(...)
  } // Τέλος fromJson


  Map<String, dynamic> toJson() { // Μετατροπή σε Map
    return <String, dynamic>{ // Επιστροφή Map
      'id': id, // id
      'tripId': tripId, // tripId
      'dateTime': dateTime.toIso8601String(), // dateTime σε ISO
      'amount': amount, // amount
      'currencyCode': currencyCode, // currencyCode
      'category': category, // category
      'paymentMethod': paymentMethod, // paymentMethod
      'note': note, // note
    }; // Τέλος Map
  } // Τέλος toJson
} // Τέλος Expense
