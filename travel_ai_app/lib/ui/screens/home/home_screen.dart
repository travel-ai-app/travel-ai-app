import 'package:flutter/material.dart';

/// Απλό HomeScreen με sections:
/// - Τίτλος + welcome text
/// - "What should I do right now?"
/// - Today ideas (chips)
/// - Trip overview (days left, total spent)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + subtitle
              const Text(
                'AI Travel Companion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome traveler 👋',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Here will live the AI suggestions.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Section: What should I do right now?
              _NowSection(),

              const SizedBox(height: 24),

              // Section: Today ideas
              const Text(
                'Today ideas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const _TodayIdeasRow(),

              const SizedBox(height: 24),
// Section: Trip overview
const Text(
  'Trip overview',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(height: 12),
const _TripOverviewRow(),

const SizedBox(height: 24),

// Section: Spending summary (placeholder)
const Text(
  'Spending summary',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(height: 12),
const _SpendingSummarySection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section: What should I do right now?
class _NowSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ What should I do right now?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here we will show AI suggestions based on your location, time and weather.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Example “input” placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: const Text(
              '💡 Example: “Walk to the nearby viewpoint for sunset, it\'s only 8 minutes away.”',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ask AI button (placeholder, χωρίς λειτουργία ακόμη)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Θα βάλουμε AI call εδώ αργότερα
              },
              child: const Text('Ask AI'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section: Today ideas (chips row)
class _TodayIdeasRow extends StatelessWidget {
  const _TodayIdeasRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: const [
        IdeaChip(label: 'Beaches 🏖️', emoji: '🏖️'),
        IdeaChip(label: 'Food & coffee ☕️', emoji: '☕️'),
        IdeaChip(label: 'Viewpoints 🌅', emoji: '🌅'),
        IdeaChip(label: 'Nightlife 🍹', emoji: '🍹'),
      ],
    );
  }
}

/// Section: Trip overview row (Days left / Total spent)
class _TripOverviewRow extends StatelessWidget {
  const _TripOverviewRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _OverviewCard(
            title: 'Days left',
            value: '5',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: 'Total spent',
            value: '€0',
          ),
        ),
      ],
    );
  }
}

/// Section: Spending summary (placeholder UI)
class _SpendingSummarySection extends StatelessWidget {
  const _SpendingSummarySection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _OverviewCard(
            title: 'Today spent',
            value: '€0',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: 'Trip total',
            value: '€0',
          ),
        ),
      ],
    );
  }
}


/// Generic card για τα overview tiles
class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;

  const _OverviewCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable chip για τις Today ideas
class IdeaChip extends StatelessWidget {
  final String label;
  final String emoji;

  const IdeaChip({
    super.key,
    required this.label,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Chip(
        avatar: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
        side: BorderSide.none,
      ),
    );
  }
}