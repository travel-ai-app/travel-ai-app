class TripDay { // Κλάση που αναπαριστά μία ημέρα του ταξιδιού
  final String id; // Μοναδικό ID της ημέρας
  final String tripId; // Συσχέτιση με το Trip (ποιο ταξίδι)
  final DateTime date; // Ημερομηνία της ημέρας
  final String? notes; // Προαιρετικές σημειώσεις για τη μέρα

  TripDay({ // Constructor
    required this.id, // Απαιτείται id
    required this.tripId, // Απαιτείται tripId
    required this.date, // Απαιτείται date
    this.notes, // Προαιρετικές notes
  }); // Τέλος constructor

  TripDay copyWith({ // Δημιουργεί νέο TripDay με αλλαγές
    String? id, // Νέο id
    String? tripId, // Νέο tripId
    DateTime? date, // Νέα date
    String? notes, // Νέες notes
  }) { // Άνοιγμα copyWith
    return TripDay( // Επιστρέφει νέο TripDay
      id: id ?? this.id, // id ή υπάρχον
      tripId: tripId ?? this.tripId, // tripId ή υπάρχον
      date: date ?? this.date, // date ή υπάρχον
      notes: notes ?? this.notes, // notes ή υπάρχουσες
    ); // Τέλος TripDay(...)
  } // Τέλος copyWith

  factory TripDay.fromJson(Map<String, dynamic> json) { // Factory από JSON
    return TripDay( // Δημιουργία TripDay
      id: json['id'] as String, // Παίρνει id
      tripId: json['tripId'] as String, // Παίρνει tripId
      date: DateTime.parse(json['date'] as String), // Κάνει parse την date
      notes: json['notes'] as String?, // Μπορεί να είναι null
    ); // Τέλος TripDay(...)
  } // Τέλος fromJson

  Map<String, dynamic> toJson() { // Μετατροπή σε Map
    return <String, dynamic>{ // Επιστροφή Map
      'id': id, // id
      'tripId': tripId, // tripId
      'date': date.toIso8601String(), // date σε ISO
      'notes': notes, // notes
    }; // Τέλος Map
  } // Τέλος toJson
} // Τέλος TripDay
