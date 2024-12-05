import 'package:flutter/material.dart';

import 'package:habits/models/category.dart';
import 'package:habits/models/habit.dart';

class ReviewStep extends StatelessWidget {
  final String title;
  final String? description;
  final Category category;
  final HabitType type;
  final int? targetValue;
  final FrequencyType frequencyType;
  final Set<int> selectedDays;
  final int? targetDays;
  final PeriodOfDay period;
  final DateTime startDate;
  final DateTime? endDate;
  final Color? color;
  final TargetCompletionType targetCompletionType;
  final String? unit;

  const ReviewStep({
    super.key,
    required this.title,
    this.description,
    required this.category,
    required this.type,
    this.targetValue,
    required this.frequencyType,
    required this.selectedDays,
    this.targetDays,
    required this.period,
    required this.startDate,
    this.endDate,
    this.color,
    required this.targetCompletionType,
    this.unit,
  });

  String _getFrequencyText() {
    if (frequencyType == FrequencyType.daily) {
      return 'Daily';
    } else if (frequencyType == FrequencyType.weekly) {
      if (targetDays != null) {
        return '$targetDays days per week';
      } else {
        final days = selectedDays.toList()..sort();
        final dayNames = days.map((day) {
          const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return weekdays[day - 1];
        }).join(', ');
        return 'Weekly on $dayNames';
      }
    } else {
      if (targetDays != null) {
        return '$targetDays days per month';
      } else {
        final dates = selectedDays.toList()..sort();
        return 'Monthly on dates: ${dates.join(', ')}';
      }
    }
  }

  String _getPeriodText() {
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

  String _getTargetCompletionText() {
    switch (targetCompletionType) {
      case TargetCompletionType.atLeast:
        return 'At Least';
      case TargetCompletionType.exactly:
        return 'Exactly';
      case TargetCompletionType.atMost:
        return 'At Most';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Habit',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your habit details carefully. Some settings cannot be changed later as they affect habit tracking calculations.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          theme,
          'Basic Information',
          [
            _buildDetail(theme, 'Title', title),
            if (description != null)
              _buildDetail(theme, 'Description', description!),
            _buildDetail(
              theme,
              'Category',
              Row(
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: Color(category.color),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          theme,
          'Habit Specifications',
          [
            _buildDetail(
              theme,
              'Type',
              type.name[0].toUpperCase() + type.name.substring(1),
            ),
            if (targetValue != null) ...[
              ListTile(
                title: const Text('Target'),
                subtitle: Text(
                  '${_getTargetCompletionText()} $targetValue${unit != null ? ' $unit' : ''}',
                ),
              ),
              _buildDetail(
                theme,
                'Target Type',
                _getTargetCompletionText(),
              ),
            ],
            _buildDetail(theme, 'Frequency', _getFrequencyText()),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          theme,
          'Schedule',
          [
            _buildDetail(theme, 'Time of Day', _getPeriodText()),
            _buildDetail(
              theme,
              'Start Date',
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
            ),
            if (endDate != null)
              _buildDetail(
                theme,
                'End Date',
                '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetail(ThemeData theme, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }
}
