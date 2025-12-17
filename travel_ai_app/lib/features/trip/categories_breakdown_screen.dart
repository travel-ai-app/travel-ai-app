import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/models/trip.dart';
import '../../core/data/in_memory_expense_repository.dart';

class CategoriesBreakdownScreen extends StatelessWidget {
  final Trip trip;

  const CategoriesBreakdownScreen({
    super.key,
    required this.trip,
  });

  List<MapEntry<String, double>> _sortedEntries(Map<String, double> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  double _totalOf(List<MapEntry<String, double>> entries) {
    return entries.fold<double>(0.0, (sum, e) => sum + e.value);
  }

  List<PieChartSectionData> _buildSections({
    required List<MapEntry<String, double>> entries,
    required double total,
    required TextStyle labelStyle,
  }) {
    // Σταθερή λίστα colors (χωρίς να “σπάει” κάθε refresh)
    final colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
    ];

    return List<PieChartSectionData>.generate(entries.length, (i) {
      final e = entries[i];
      final percent = total > 0 ? (e.value / total) * 100 : 0.0;

      // Δείχνουμε label μόνο αν είναι αρκετά μεγάλο slice
      final showLabel = percent >= 8;

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: e.value,
        title: showLabel ? '${percent.toStringAsFixed(0)}%' : '',
        radius: 60,
        titleStyle: labelStyle,
      );
    });
  }

  Widget _buildLegend({
    required List<MapEntry<String, double>> entries,
    required double total,
    required String currency,
  }) {
    final colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
    ];

    return Column(
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final percent = total > 0 ? (e.value / total) * 100 : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${e.value.toStringAsFixed(0)} $currency',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = InMemoryExpenseRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending by category'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: repo.getTotalsByCategoryForTrip(trip),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? <String, double>{};

          if (data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No expenses yet.\nAdd some expenses to see category breakdown.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final entries = _sortedEntries(data);
          final total = _totalOf(entries);
          final currency = trip.currencyCode;

          // Αν total=0 για κάποιο λόγο, fallback
          if (total <= 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Total is 0.\nAdd expenses to see breakdown.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sections = _buildSections(
            entries: entries,
            total: total,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ✅ Pie chart card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: ${total.toStringAsFixed(0)} $currency',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLegend(
                        entries: entries,
                        total: total,
                        currency: currency,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Η λίστα όπως την είχες (progress bars)
              const Text(
                'All categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(entries.length, (index) {
                final entry = entries[index];
                final amount = entry.value;
                final percent = (amount / total) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (percent / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${amount.toStringAsFixed(0)} $currency',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
