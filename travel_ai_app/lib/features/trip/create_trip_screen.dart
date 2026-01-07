import 'package:flutter/material.dart'; // flutter //
import 'package:travel_ai_app/core/models/trip.dart'; // model //
import 'package:travel_ai_app/core/constants/app_limits.dart'; // limits //
import 'package:travel_ai_app/presentation/upgrade_dialog.dart'; // upgrade dialog //
import 'package:travel_ai_app/core/monetization/monetization_gate.dart'; // gate //
import 'package:travel_ai_app/core/monetization/monetization_state.dart'; // state //


class CreateTripScreen extends StatefulWidget {
  final Trip? existingTrip; // null = create, not null = edit //

  const CreateTripScreen({super.key, this.existingTrip}); // ctor //

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState(); // state //
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>(); // form key //

  final _titleController = TextEditingController(); // title //
  final _destinationController = TextEditingController(); // destination //

  DateTime? _startDate; // start //
  DateTime? _endDate; // end //

  bool get _isEdit => widget.existingTrip != null; // mode //

  @override
  void initState() {
    super.initState(); // init //

    final existing = widget.existingTrip; // existing //
    if (existing != null) {
      _titleController.text = existing.title; // prefill title //
      _destinationController.text = existing.destination; // prefill destination //

      // ✅ strip time for stability //
      _startDate = DateTime(
        existing.startDate.year,
        existing.startDate.month,
        existing.startDate.day,
      ); // start //
      _endDate = DateTime(
        existing.endDate.year,
        existing.endDate.month,
        existing.endDate.day,
      ); // end //
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // dispose //
    _destinationController.dispose(); // dispose //
    super.dispose(); // dispose //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Trip' : 'Create Trip'), // title //
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // padding //
        child: Form(
          key: _formKey, // key //
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController, // controller //
                decoration: const InputDecoration(
                  labelText: 'Trip title', // label //
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title'; // validation //
                  }
                  return null; // ok //
                },
              ),
              const SizedBox(height: 16), // gap //
              TextFormField(
                controller: _destinationController, // controller //
                decoration: const InputDecoration(
                  labelText: 'Destination', // label //
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a destination'; // validation //
                  }
                  return null; // ok //
                },
              ),
              const SizedBox(height: 24), // gap //
              _buildDatePickerRow(
                context: context, // ctx //
                label: 'Start date', // label //
                selectedDate: _startDate, // date //
                onTap: () => _pickDate(isStart: true), // tap //
              ),
              const SizedBox(height: 12), // gap //
              _buildDatePickerRow(
                context: context, // ctx //
                label: 'End date', // label //
                selectedDate: _endDate, // date //
                onTap: () => _pickDate(isStart: false), // tap //
              ),
              const SizedBox(height: 32), // gap //
              ElevatedButton(
                onPressed: _onSavePressed, // save //
                child: Text(_isEdit ? 'Save changes' : 'Save trip'), // text //
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow({
    required BuildContext context, // ctx //
    required String label, // label //
    required DateTime? selectedDate, // date //
    required VoidCallback onTap, // tap //
  }) {
    final text = selectedDate == null
        ? 'Select date' // empty //
        : '${selectedDate.day.toString().padLeft(2, '0')}/' // dd //
            '${selectedDate.month.toString().padLeft(2, '0')}/' // mm //
            '${selectedDate.year}'; // yyyy //

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed: onTap, // open picker //
          child: Text(text), // date text //
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    // ✅ choose safe initialDate //
    final DateTime now = DateTime.now(); // now //
    final DateTime safeNow = DateTime(now.year, now.month, now.day); // strip //

    DateTime initialDate; // initial //
    if (isStart) {
      initialDate = _startDate ?? safeNow; // start //
    } else {
      initialDate = _endDate ?? (_startDate ?? safeNow); // end prefers start //
    }

    // ✅ strip & safe bounds //
    final DateTime firstDate = DateTime(2020, 1, 1); // first //
    final DateTime lastDate = DateTime(2100, 12, 31); // last //

    if (initialDate.isBefore(firstDate)) initialDate = firstDate; // clamp //
    if (initialDate.isAfter(lastDate)) initialDate = lastDate; // clamp //

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return; // cancelled //
    if (!mounted) return; // safety //

    final DateTime newDate = DateTime(picked.year, picked.month, picked.day); // strip //

    setState(() {
      if (isStart) {
        _startDate = newDate; // set start //
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate; // align //
        }
      } else {
        _endDate = newDate; // set end //
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate; // align (extra safety) //
        }
      }
    });
  }

  Future<void> _onSavePressed() async {
    final formValid = _formKey.currentState?.validate() ?? false; // validate //
    if (!formValid) return; // stop //

    if (_startDate == null || _endDate == null) {
      _showError('Please select both start and end dates'); // error //
      return; // stop //
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('End date cannot be before start date'); // error //
      return; // stop //
    }

    final int dayCount = _endDate!.difference(_startDate!).inDays + 1; // days //

    // 🔒 v1 LIMIT: max days per trip (works for create + edit) //
final gate = MonetizationGate.canCreateTripWithDays( // gate check //
  state: AppLimits.isPro // current tier source //
      ? MonetizationState.premium // premium //
      : MonetizationState.free, // free //
  activeTripsCount: 0, // not relevant here; create/edit screen only checks days //
  requestedDays: dayCount, // requested days //
); // end gate //

final canProceed = await ensureAllowedOrShowUpgrade( // defensive helper //
  context: context, // ctx //
  gate: gate, // gate result //
); // end helper //

if (!canProceed) { // blocked //
  return; // stop save //
} // end blocked //



    final existing = widget.existingTrip; // existing //
    final trip = Trip(
      id: existing?.id ?? 'trip_${DateTime.now().millisecondsSinceEpoch}', // keep id //
      title: _titleController.text.trim(), // title //
      destination: _destinationController.text.trim(), // destination //
      startDate: _startDate!, // start //
      endDate: _endDate!, // end //
      currencyCode: existing?.currencyCode ?? 'EUR', // keep currency //
      baseBudget: existing?.baseBudget, // keep budget //
    );

    if (!mounted) return; // safety //
    Navigator.of(context).pop(trip); // return trip //
  }

  void _showError(String message) {
    if (!mounted) return; // analyzer-safe //
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // snackbar //
    );
  }
}
