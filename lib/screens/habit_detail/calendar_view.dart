import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:habits/core/extensions/date_extension.dart';
import 'package:habits/models/habit_entry_extended.dart';
import 'package:habits/services/service_locator.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.habit,
  });

  final Habit? habit;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _habitEntryService = serviceLocator.habitEntryService;
  late DateTime _selectedMonth;
  late List<DateTime> _daysInMonth;
  Map<String, HabitEntryExtended> _entries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _updateDaysInMonth();
    _loadEntries();
  }

  void _updateDaysInMonth() {
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    // Get the first day of the week for the first day of the month
    final firstWeekday = firstDayOfMonth.weekday;
    final daysBeforeMonth = List.generate(
        firstWeekday - 1,
        (index) =>
            firstDayOfMonth.subtract(Duration(days: firstWeekday - index - 1)));

    // Get all days in the month
    final daysInMonth = List.generate(
      lastDayOfMonth.day,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );

    // Get the remaining days to complete the last week
    final lastWeekday = lastDayOfMonth.weekday;
    final daysAfterMonth = List.generate(
      7 - lastWeekday,
      (index) => lastDayOfMonth.add(Duration(days: index + 1)),
    );

    _daysInMonth = [...daysBeforeMonth, ...daysInMonth, ...daysAfterMonth];
  }

  Future<void> _loadEntries() async {
    if (widget.habit == null) return;

    setState(() {
      _isLoading = true;
    });

    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    _entries = await _habitEntryService.getEntriesForHabit(
      widget.habit!.id,
      startDate,
      endDate,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _updateDaysInMonth();
      _loadEntries();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _updateDaysInMonth();
      _loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habit == null) {
      return const Center(
        child: Text('Habit not found'),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _daysInMonth.length,
          itemBuilder: (context, index) {
            final day = _daysInMonth[index];
            final isCurrentMonth = day.month == _selectedMonth.month;
            final dateString = day.toShortDateString();
            final entry = _entries[dateString];
            final isAvailable = widget.habit!.availableAtDate(day);

            final isSucceeded = entry?.status == HabitEntryStatus.success;
            final isFailed = entry?.status == HabitEntryStatus.failed;

            final borderColor = isSucceeded
                ? Theme.of(context).colorScheme.primary
                : isFailed
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outlineVariant;

            final backgroundColor = !isAvailable
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : isSucceeded
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.4)
                    : isFailed
                        ? Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(0.4)
                        : null;

            final borderWidth = entry?.entry != null ? 2.0 : 1.5;

            return DecoratedBox(
              decoration: BoxDecoration(
                shape: isFailed ? BoxShape.rectangle : BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                borderRadius: isFailed ? BorderRadius.circular(8) : null,
                color: backgroundColor,
              ),
              child: Center(
                child: Text(
                  day.day.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: !isCurrentMonth || !isAvailable
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ),
    );
  }
}
