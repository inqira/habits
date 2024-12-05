import 'package:flutter/material.dart';

class SettingsStep extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const SettingsStep({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        ListTile(
          title: const Text('Start Date'),
          subtitle: Text(
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (date != null) {
              onStartDateChanged(date);
            }
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('End Date (Optional)'),
          subtitle: Text(
            endDate != null
                ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                : 'No end date',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: startDate,
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            onEndDateChanged(date);
          },
        ),
        const SizedBox(height: 8),
     ],
    );
  }
}
