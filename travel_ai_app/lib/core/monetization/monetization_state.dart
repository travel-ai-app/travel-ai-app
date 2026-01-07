// travel_ai_app/lib/core/monetization/monetization_state.dart // file path //

enum UserTier { // subscription tier enum //
  free, // free tier //
  premium, // premium tier //
} // end enum //

class MonetizationState { // single source of truth for monetization state //
  final UserTier tier; // current user tier //

  const MonetizationState({ // const ctor //
    required this.tier, // required tier //
  }); // end ctor //

  bool get isPremium => tier == UserTier.premium; // helper flag //
  bool get isFree => tier == UserTier.free; // helper flag //

  static const MonetizationState free = // predefined free state //
      MonetizationState(tier: UserTier.free); // free //

  static const MonetizationState premium = // predefined premium state //
      MonetizationState(tier: UserTier.premium); // premium //
} // end class //
