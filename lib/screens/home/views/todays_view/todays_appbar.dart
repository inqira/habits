import 'package:flutter/material.dart';

class TodaysAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final DateTime firstHabitDay;
  final Function(DateTime) onDateSelected;

  const TodaysAppBar({
    super.key,
    required this.selectedDate,
    required this.firstHabitDay,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Today'),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(firstHabitDay.year, firstHabitDay.month, firstHabitDay.day),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Help'),
                content: const Text(
                  'Tap on a habit to mark it as complete.\n\n'
                  'Long press on a habit to enter a specific value.\n\n'
                  'Use the calendar icon to jump to a specific date.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
