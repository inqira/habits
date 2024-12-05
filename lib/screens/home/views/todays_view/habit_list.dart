import 'package:flutter/material.dart';

import 'package:habits/models/category.dart';
import 'package:habits/models/habit_entry_extended.dart';
import 'package:habits/screens/home/views/todays_view/habit_list_item.dart';
import 'package:habits/services/service_locator.dart';

class HabitList extends StatelessWidget {
  final List<HabitEntryExtended> habitEntries;
  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(HabitEntryExtended) onCycleStatus;
  final void Function(HabitEntryExtended) onValueInputRequested;

  const HabitList({
    super.key,
    required this.habitEntries,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCycleStatus,
    required this.onValueInputRequested,
  });

  String _getPeriodTitle(PeriodOfDay period) {
    switch (period) {
      case PeriodOfDay.morning:
        return 'Morning';
      case PeriodOfDay.afternoon:
        return 'Afternoon';
      case PeriodOfDay.evening:
        return 'Evening';
      case PeriodOfDay.anytime:
        return 'Anytime';
    }
  }

  IconData _getPeriodIcon(PeriodOfDay period) {
    switch (period) {
      case PeriodOfDay.morning:
        return Icons.wb_sunny_outlined;
      case PeriodOfDay.afternoon:
        return Icons.wb_cloudy_outlined;
      case PeriodOfDay.evening:
        return Icons.dark_mode_outlined;
      case PeriodOfDay.anytime:
        return Icons.schedule_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHabits = selectedCategoryId != null
        ? habitEntries
            .where((entry) => entry.habit.categoryId == selectedCategoryId)
            .toList()
        : habitEntries;

    if (filteredHabits.isEmpty) {
      return const Center(
        child: Text('No habits found'),
      );
    }

    // Group habits by period
    final groupedHabits = <PeriodOfDay, List<HabitEntryExtended>>{};
    for (final period in PeriodOfDay.values) {
      final habitsInPeriod = filteredHabits
          .where((entry) => entry.habit.period == period)
          .toList();
      if (habitsInPeriod.isNotEmpty) {
        groupedHabits[period] = habitsInPeriod;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groupedHabits.length,
        itemBuilder: (context, index) {
          final period = groupedHabits.keys.elementAt(index);
          final habitsInPeriod = groupedHabits[period]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      _getPeriodIcon(period),
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPeriodTitle(period),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habitsInPeriod.length,
                itemBuilder: (context, habitIndex) {
                  final habitEntry = habitsInPeriod[habitIndex];
                  final category = serviceLocator.categoryService
                      .getCategoryById(habitEntry.habit.categoryId);

                  return HabitListItem(
                    category: category,
                    habitEntry: habitEntry,
                    onCycleStatus: onCycleStatus,
                    onValueInputRequested: onValueInputRequested,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
