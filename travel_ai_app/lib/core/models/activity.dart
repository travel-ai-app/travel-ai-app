import 'day_part.dart'; // Πρωί / Απόγευμα / Βράδυ

/// Μοντέλο μίας δραστηριότητας μέσα σε ταξίδι.
/// Περιέχει βασικές πληροφορίες + προαιρετικά metadata.
class Activity {
  final String id;                     // Μοναδικό ID δραστηριότητας
  final String title;                  // Τίτλος (π.χ. "Big Buddha Temple")
  final String? description;           // Προαιρετική περιγραφή
  final DateTime? date;                // Ημερομηνία που γίνεται (αν υπάρχει)

  /// Εκτιμώμενο κόστος (όνομα που χρησιμοποιεί ο παλιός κώδικάς σου).
  final double? estimatedCost;         // Π.χ. 500.0

  final String? currencyCode;          // Π.χ. "EUR", "USD", "THB"
  final String? category;              // Π.χ. "Food", "Beach", "Culture"
  final String? placeId;               // Google Place ID (προαιρετικό)
  final double? rating;                // Rating από API
  final int? ratingCount;              // Πλήθος reviews

  /// Επιπλέον πεδία που χρησιμοποιούσε το παλιό demo / mock data.
  final String? tripId;                // ID του trip στο οποίο ανήκει
  final String? dayId;                 // ID της ημέρας (TripDay) στην οποία ανήκει

  /// Νέο πεδίο: Πρωί / Απόγευμα / Βράδυ
  final DayPart dayPart;

  const Activity({
    required this.id,
    required this.title,
    required this.dayPart,             // Υποχρεωτικό (αλλά μπορούμε να βάζουμε DayPart.morning)
    this.description,
    this.date,
    this.estimatedCost,
    this.currencyCode,
    this.category,
    this.placeId,
    this.rating,
    this.ratingCount,
    this.tripId,
    this.dayId,
  });

  /// Δημιουργία Activity από JSON.
  /// Προσπαθούμε να είμαστε συμβατοί: αν υπάρχει 'estimatedCost' ή 'cost'.
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      dayPart: _parseDayPart(json['dayPart']),
      description: json['description'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ??
          (json['cost'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String?,
      category: json['category'] as String?,
      placeId: json['placeId'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      tripId: json['tripId'] as String?,
      dayId: json['dayId'] as String?,
    );
  }

  static DayPart _parseDayPart(dynamic raw) {
    if (raw is String) {
      switch (raw) {
        case 'morning':
        case 'DayPart.morning':
          return DayPart.morning;
        case 'afternoon':
        case 'DayPart.afternoon':
          return DayPart.afternoon;
        case 'evening':
        case 'DayPart.evening':
          return DayPart.evening;
      }
    }
    return DayPart.morning; // Fallback ασφαλείας
  }

  /// Επιστροφή σε JSON (π.χ. για Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dayPart': dayPart.name,
      'description': description,
      'date': date?.toIso8601String(),
      'estimatedCost': estimatedCost,
      'currencyCode': currencyCode,
      'category': category,
      'placeId': placeId,
      'rating': rating,
      'ratingCount': ratingCount,
      'tripId': tripId,
      'dayId': dayId,
    };
  }

  /// Copy-with (immutable update)
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    double? estimatedCost,
    String? currencyCode,
    String? category,
    String? placeId,
    double? rating,
    int? ratingCount,
    String? tripId,
    String? dayId,
    DayPart? dayPart,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      placeId: placeId ?? this.placeId,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      tripId: tripId ?? this.tripId,
      dayId: dayId ?? this.dayId,
      dayPart: dayPart ?? this.dayPart,
    );
  }
}
