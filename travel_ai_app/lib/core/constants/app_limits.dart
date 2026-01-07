import 'package:travel_ai_app/core/monetization/monetization_state.dart'; // state //

class AppLimits { // limits container //

  static const bool isPro = false; // v1/v2: always false (no billing yet) //

  static const int freeMaxActiveTrips = 1; // free: 1 active trip //
  static const int freeMaxTripDays = 5; // free: max 5 days per trip //

  // 🔐 Single source of truth for current monetization state //
  static MonetizationState get currentState => // getter //
      isPro ? MonetizationState.premium : MonetizationState.free; // map //

} // end AppLimits //
