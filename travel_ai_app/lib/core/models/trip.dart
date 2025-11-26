class Trip { // Κλάση που αναπαριστά ένα ταξίδι
  final String id; // Μοναδικό ID του ταξιδιού
  final String title; // Τίτλος ταξιδιού (π.χ. "Thailand Adventure")
  final String destination; // Προορισμός (π.χ. "Phuket, Thailand")
  final DateTime startDate; // Ημερομηνία έναρξης ταξιδιού
  final DateTime endDate; // Ημερομηνία λήξης ταξιδιού
  final String currencyCode; // Νόμισμα του ταξιδιού (π.χ. "EUR", "THB")
  final double? baseBudget; // Προαιρετικό αρχικό budget για το ταξίδι

  Trip({ // Κανονικός constructor
    required this.id, // Απαιτείται id
    required this.title; // Απαιτείται τίτλος
    required this.destination; // Απαιτείται προορισμός
    required this.startDate; // Απαιτείται startDate
    required this.endDate; // Απαιτείται endDate
    required this.currencyCode; // Απαιτείται νόμισμα
    this.baseBudget; // Προαιρετικό budget
  }); // Τέλος constructor

  int get totalDays => endDate.difference(startDate).inDays + 1; // Συνολικές μέρες ταξιδιού

  Trip copyWith({ // Μέθοδος για δημιουργία νέου Trip με αλλαγμένα πεδία
    String? id, // Προαιρετική αλλαγή id
    String? title, // Προαιρετική αλλαγή τίτλου
    String? destination, // Προαιρετική αλλαγή προορισμού
    DateTime? startDate, // Προαιρετική αλλαγή startDate
    DateTime? endDate, // Προαιρετική αλλαγή endDate
    String? currencyCode, // Προαιρετική αλλαγή νομίσματος
    double? baseBudget, // Προαιρετική αλλαγή budget
  }) { // Άνοιγμα μεθόδου copyWith
    return Trip( // Επιστρέφει νέο Trip
      id: id ?? this.id, // Αν δεν δοθεί, κρατά το υπάρχον id
      title: title ?? this.title, // Αν δεν δοθεί, κρατά τον υπάρχοντα τίτλο
      destination: destination ?? this.destination, // Προορισμός
      startDate: startDate ?? this.startDate, // Start date
      endDate: endDate ?? this.endDate, // End date
      currencyCode: currencyCode ?? this.currencyCode, // Νόμισμα
      baseBudget: baseBudget ?? this.baseBudget, // Budget
    ); // Τέλος Trip(...)
  } // Τέλος copyWith

  factory Trip.fromJson(Map<String, dynamic> json) { // Factory constructor από JSON
    return Trip( // Δημιουργεί Trip από Map
      id: json['id'] as String, // Παίρνει id από JSON
      title: json['title'] as String, // Παίρνει title
      destination: json['destination'] as String, // Παίρνει destination
      startDate: DateTime.parse(json['startDate'] as String), // Κάνει parse την startDate
      endDate: DateTime.parse(json['endDate'] as String), // Κάνει parse την endDate
      currencyCode: json['currencyCode'] as String, // Παίρνει currencyCode
      baseBudget: json['baseBudget'] != null // Αν υπάρχει baseBudget
          ? (json['baseBudget'] as num).toDouble() // Το μετατρέπει σε double
          : null, // Αλλιώς null
    ); // Τέλος Trip(...)
  } // Τέλος fromJson

  Map<String, dynamic> toJson() { // Μετατρέπει το Trip σε Map
    return <String, dynamic>{ // Επιστρέφει Map
      'id': id, // Αποθήκευση id
      'title': title, // Αποθήκευση title
      'destination': destination, // Αποθήκευση destination
      'startDate': startDate.toIso8601String(), // Ημερομηνία σε ISO String
      'endDate': endDate.toIso8601String(), // Ημερομηνία σε ISO String
      'currencyCode': currencyCode, // Αποθήκευση νομίσματος
      'baseBudget': baseBudget, // Αποθήκευση budget (μπορεί να είναι null)
    }; // Τέλος Map
  } // Τέλος toJson
} // Τέλος κλάσης Trip
