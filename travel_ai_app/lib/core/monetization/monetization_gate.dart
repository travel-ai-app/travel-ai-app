// travel_ai_app/lib/core/monetization/monetization_gate.dart // file path //

import '../constants/app_limits.dart'; // limits source //
import 'monetization_state.dart'; // MonetizationState //

enum GateResult { // result of a gate check //
  allowed, // user can proceed //
  blockedTripsLimit, // blocked by max active trips //
  blockedDaysLimit, // blocked by max trip days //
} // end enum //

class MonetizationGate { // central feature gating logic //
  const MonetizationGate._(); // no instances //

  static GateResult canCreateTrip({ // check if user can create a trip //
    required MonetizationState state, // user monetization state //
    required int activeTripsCount, // current active trips //
  }) { // start //
    if (state.isPremium) { // premium bypass //
      return GateResult.allowed; // allowed //
    } // end premium //

    if (activeTripsCount >= AppLimits.freeMaxActiveTrips) { // trip limit //
      return GateResult.blockedTripsLimit; // blocked //
    } // end trip limit //

    return GateResult.allowed; // allowed //
  } // end canCreateTrip //

  static GateResult canCreateTripWithDays({ // check trip creation with days constraint //
    required MonetizationState state, // user monetization state //
    required int activeTripsCount, // current active trips //
    required int requestedDays, // days user selected //
  }) { // start //
    final tripGate = canCreateTrip( // first gate //
      state: state, // pass state //
      activeTripsCount: activeTripsCount, // pass active trips //
    ); // end call //

    if (tripGate != GateResult.allowed) { // blocked already //
      return tripGate; // return reason //
    } // end blocked //

    if (state.isPremium) { // premium bypass //
      return GateResult.allowed; // allowed //
    } // end premium //

    if (requestedDays > AppLimits.freeMaxTripDays) { // days limit //
      return GateResult.blockedDaysLimit; // blocked //
    } // end days limit //

    return GateResult.allowed; // allowed //
  } // end canCreateTripWithDays //
} // end class //
