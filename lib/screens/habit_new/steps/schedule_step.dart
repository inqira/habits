import 'package:flutter/material.dart';

import 'package:habits/models/habit.dart';

class ScheduleStep extends StatelessWidget {
  final PeriodOfDay period;
  final ValueChanged<PeriodOfDay> onPeriodChanged;
  final Widget Function<T>({
    required T value,
    required T groupValue,
    required String title,
    required IconData icon,
    String? subtitle,
    required ValueChanged<T> onChanged,
  }) buildSelectionTile;

  const ScheduleStep({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.buildSelectionTile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's plan your schedule!",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Text(
          'What time of day works best?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        buildSelectionTile(
          value: PeriodOfDay.morning,
          groupValue: period,
          title: 'Morning',
          icon: Icons.wb_sunny_outlined,
          onChanged: onPeriodChanged,
        ),
        const SizedBox(height: 8),
        buildSelectionTile(
          value: PeriodOfDay.afternoon,
          groupValue: period,
          title: 'Afternoon',
          icon: Icons.wb_cloudy_outlined,
          onChanged: onPeriodChanged,
        ),
        const SizedBox(height: 8),
        buildSelectionTile(
          value: PeriodOfDay.evening,
          groupValue: period,
          title: 'Evening',
          icon: Icons.nights_stay_outlined,
          onChanged: onPeriodChanged,
        ),
        const SizedBox(height: 8),
        buildSelectionTile(
          value: PeriodOfDay.anytime,
          groupValue: period,
          title: 'Anytime',
          icon: Icons.access_time,
          onChanged: onPeriodChanged,
        ),
      ],
    );
  }
}
