import 'package:flutter/material.dart';

import 'package:habits/screens/habit_detail/calendar_view.dart';
import 'package:habits/services/service_locator.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({
    super.key,
    required this.habitId,
  });

  final String habitId;

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _habitService = serviceLocator.habitService;
  final _categoryService = serviceLocator.categoryService;

  @override
  Widget build(BuildContext context) {
    final habit = _habitService.getHabit(widget.habitId);

    if (habit == null) {
      return const Center(
        child: Text('Habit not found'),
      );
    }

    final category = _categoryService.getCategoryById(habit.categoryId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (habit.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              habit.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
          ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          CalendarView(
            habit: habit,
          ),
        ],
      ),
    );
  }
}
