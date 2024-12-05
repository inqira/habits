import 'package:flutter/material.dart';

import 'package:habits/models/category.dart';
import 'package:habits/models/habit_entry_extended.dart';

class HabitListItem extends StatelessWidget {
  final Category category;
  final HabitEntryExtended habitEntry;
  final void Function(HabitEntryExtended) onCycleStatus;
  final void Function(HabitEntryExtended) onValueInputRequested;

  const HabitListItem({
    super.key,
    required this.category,
    required this.habitEntry,
    required this.onCycleStatus,
    required this.onValueInputRequested,
  });

  Habit get habit => habitEntry.habit;

  Widget _buildStatusIcon(BuildContext context) {
    final status = habitEntry.entry?.status;
    final currentValue = habitEntry.value;

    IconData getIconData() {
      if (status == HabitEntryStatus.success) return Icons.check_circle;
      if (status == HabitEntryStatus.failed) return Icons.cancel;
      return currentValue > 0
          ? Icons.circle_outlined
          : Icons.radio_button_unchecked;
    }

    Color getIconColor(BuildContext context) {
      if (status == HabitEntryStatus.success) {
        return Theme.of(context).colorScheme.primary;
      }
      if (status == HabitEntryStatus.failed) {
        return Theme.of(context).colorScheme.error;
      }
      return currentValue > 0
          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
          : Theme.of(context).disabledColor;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: animation,
            child: child,
          ),
        );
      },
      child: Icon(
        getIconData(),
        key: ValueKey(status),
        color: getIconColor(context),
        size: 24,
      ),
    );
  }

  Widget? _buildSubtitle() {
    final currentValue = habitEntry.value;

    String subtitle = '';
    if (habit.type == HabitType.numeric) {
      subtitle = '$currentValue / ${habit.targetValue}';
    } else if (habit.type == HabitType.duration) {
      final currentDuration = Duration(seconds: currentValue);
      final targetDuration = Duration(seconds: habit.targetValue);
      subtitle =
          '${_formatDuration(currentDuration)} / ${_formatDuration(targetDuration)}';
    }

    return subtitle.isEmpty ? null : Text(subtitle);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = habitEntry.habit;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () {
            if (habit.type == HabitType.checkbox) {
              onCycleStatus(habitEntry);
            } else {
              onValueInputRequested(habitEntry);
            }
          },
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(
              category.icon,
              color: Color(category.color),
              size: 20,
            ),
            title: Text(
              habit.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: _buildSubtitle(),
            trailing: habit.type == HabitType.checkbox
                ? _buildStatusIcon(context)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusIcon(context),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onValueInputRequested(habitEntry),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
