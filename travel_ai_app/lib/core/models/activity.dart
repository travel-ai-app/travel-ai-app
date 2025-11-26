class Activity { // Κλάση για δραστηριότητα ταξιδιού
  final String id; // Μοναδικό ID δραστηριότητας
  final String tripId; // Σε ποιο ταξίδι ανήκει
  final String? dayId; // Προαιρετικό, σε ποια μέρα του trip (TripDay) ανήκει
  final String title; // Τίτλος δραστηριότητας (π.χ. "Boat tour to Phi Phi")
  final String? description; // Προαιρετική περιγραφή
  final String? type; // Τύπος (π.χ. "activity", "food", "nightlife")
  final String? locationName; // Όνομα τοποθεσίας (π.χ. "Patong Beach")
  final double? latitude; // Γεωγραφικό πλάτος
  final double? longitude; // Γεωγραφικό μήκος
  final DateTime? startTime; // Ώρα έναρξης
  final DateTime? endTime; // Ώρα λήξης
  final double? estimatedCost; // Εκτιμώμενο κόστος
  final String? currencyCode; // Νόμισμα για το κόστος
  final double? rating; // Rating από APIs (π.χ. 4.7)
  final int? reviewCount; // Αριθμός reviews
  final String? bookingUrl; // Link για booking αν υπάρχει

  Activity({ // Constructor
    required this.id, // Απαιτείται id
    required this.tripId, // Απαιτείται tripId
    this.dayId, // Προαιρετικό dayId
    required this.title, // Απαιτείται title
    this.description, // Προαιρετικό description
    this.type, // Προαιρετικό type
    this.locationName, // Προαιρετικό locationName
    this.latitude, // Προαιρετικό latitude
    this.longitude, // Προαιρετικό longitude
    this.startTime, // Προαιρετικό startTime
    this.endTime, // Προαιρετικό endTime
    this.estimatedCost, // Προαιρετικό estimatedCost
    this.currencyCode, // Προαιρετικό currencyCode
    this.rating, // Προαιρετικό rating
    this.reviewCount, // Προαιρετικό reviewCount
    this.bookingUrl, // Προαιρετικό bookingUrl
  }); // Τέλος constructor

  Activity copyWith({ // Μέθοδος για νέο Activity με αλλαγές
    String? id, // Νέο id
    String? tripId, // Νέο tripId
    String? dayId, // Νέο dayId
    String? title, // Νέο title
    String? description, // Νέο description
    String? type, // Νέο type
    String? locationName, // Νέο locationName
    double? latitude, // Νέο latitude
    double? longitude, // Νέο longitude
    DateTime? startTime, // Νέο startTime
    DateTime? endTime, // Νέο endTime
    double? estimatedCost, // Νέο estimatedCost
    String? currencyCode, // Νέο currencyCode
    double? rating, // Νέο rating
    int? reviewCount, // Νέο reviewCount
    String? bookingUrl, // Νέο bookingUrl
  }) { // Άνοιγμα copyWith
    return Activity( // Επιστρέφει νέο Activity
      id: id ?? this.id, // id
      tripId: tripId ?? this.tripId, // tripId
      dayId: dayId ?? this.dayId, // dayId
      title: title ?? this.title, // title
      description: description ?? this.description, // description
      type: type ?? this.type, // type
      locationName: locationName ?? this.locationName, // locationName
      latitude: latitude ?? this.latitude, // latitude
      longitude: longitude ?? this.longitude, // longitude
      startTime: startTime ?? this.startTime, // startTime
      endTime: endTime ?? this.endTime, // endTime
      estimatedCost: estimatedCost ?? this.estimatedCost, // estimatedCost
      currencyCode: currencyCode ?? this.currencyCode, // currencyCode
      rating: rating ?? this.rating, // rating
      reviewCount: reviewCount ?? this.reviewCount, // reviewCount
      bookingUrl: bookingUrl ?? this.bookingUrl, // bookingUrl
    ); // Τέλος Activity(...)
  } // Τέλος copyWith

  factory Activity.fromJson(Map<String, dynamic> json) { // Factory από JSON
    return Activity( // Δημιουργία Activity
      id: json['id'] as String, // id
      tripId: json['tripId'] as String, // tripId
      dayId: json['dayId'] as String?, // dayId
      title: json['title'] as String, // title
      description: json['description'] as String?, // description
      type: json['type'] as String?, // type
      locationName: json['locationName'] as String?, // locationName
      latitude: json['latitude'] != null // Αν υπάρχει latitude
          ? (json['latitude'] as num).toDouble() // Μετατροπή σε double
          : null, // Αλλιώς null
      longitude: json['longitude'] != null // Αν υπάρχει longitude
          ? (json['longitude'] as num).toDouble() // Μετατροπή σε double
          : null, // Αλλιώς null
      startTime: json['startTime'] != null // Αν υπάρχει startTime
          ? DateTime.parse(json['startTime'] as String) // Parse σε DateTime
          : null, // Αλλιώς null
      endTime: json['endTime'] != null // Αν υπάρχει endTime
          ? DateTime.parse(json['endTime'] as String) // Parse σε DateTime
          : null, // Αλλιώς null
      estimatedCost: json['estimatedCost'] != null // Αν υπάρχει estimatedCost
          ? (json['estimatedCost'] as num).toDouble() // double
          : null, // Αλλιώς null
      currencyCode: json['currencyCode'] as String?, // currencyCode
      rating: json['rating'] != null // Αν υπάρχει rating
          ? (json['rating'] as num).toDouble() // double
          : null, // Αλλιώς null
      reviewCount: json['reviewCount'] as int?, // reviewCount
      bookingUrl: json['bookingUrl'] as String?, // bookingUrl
    ); // Τέλος Activity(...)
  } // Τέλος fromJson

  Map<String, dynamic> toJson() { // Μετατροπή σε Map
    return <String, dynamic>{ // Επιστροφή Map
      'id': id, // id
      'tripId': tripId, // tripId
      'dayId': dayId, // dayId
      'title': title, // title
      'description': description, // description
      'type': type, // type
      'locationName': locationName, // locationName
      'latitude': latitude, // latitude
      'longitude': longitude, // longitude
      'startTime': startTime?.toIso8601String(), // startTime ή null
      'endTime': endTime?.toIso8601String(), // endTime ή null
      'estimatedCost': estimatedCost, // estimatedCost
      'currencyCode': currencyCode, // currencyCode
      'rating': rating, // rating
      'reviewCount': reviewCount, // reviewCount
      'bookingUrl': bookingUrl, // bookingUrl
    }; // Τέλος Map
  } // Τέλος toJson
} // Τέλος Activity
