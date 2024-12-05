import 'package:flutter/material.dart';

import 'package:habits/models/habit.dart';
import 'package:habits/services/service_locator.dart';
import 'package:habits/services/statistics_service.dart';

class StatisticsTab extends StatelessWidget {
  final String habitId;

  const StatisticsTab({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    final habit = serviceLocator.habitService.getHabit(habitId);
    if (habit == null) {
      return const Center(child: Text('Habit not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Widget>(
            future: _buildTimeframeStats(
              title: 'Today',
              habit: habit,
              timeframe: StatisticsTimeframe.today(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<Widget>(
            future: _buildTimeframeStats(
              title: 'This Week',
              habit: habit,
              timeframe: StatisticsTimeframe.thisWeek(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<Widget>(
            future: _buildTimeframeStats(
              title: 'This Month',
              habit: habit,
              timeframe: StatisticsTimeframe.thisMonth(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<Widget>(
            future: _buildTimeframeStats(
              title: 'Overall',
              habit: habit,
              timeframe: StatisticsTimeframe.overall(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildTimeframeStats({
    required String title,
    required Habit habit,
    required StatisticsTimeframe timeframe,
  }) async {
    final stats = await serviceLocator.statisticsService.calculateStatistics(
      habit.id,
      timeframe,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Success Rate',
                    value: '${stats.successRate.toStringAsFixed(1)}%',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    label: 'Completion Rate',
                    value: '${stats.completionRate.toStringAsFixed(1)}%',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Successful Days',
                    value: stats.successfulEntries.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    label: 'Failed Days',
                    value: stats.failedEntries.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (habit.type != HabitType.checkbox) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Average Value',
                      value: stats.averageValue.toStringAsFixed(1),
                      color: Colors.orange,
                      suffix: habit.unit,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Total Value',
                      value: stats.totalValue.toString(),
                      color: Colors.purple,
                      suffix: habit.unit,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
