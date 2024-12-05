import 'package:flutter/material.dart';

import 'package:habits/models/habit.dart';

class HabitValueInput extends StatelessWidget {
  final Habit habit;
  final double? currentValue;
  final ValueChanged<double?> onValueChanged;

  const HabitValueInput({
    super.key,
    required this.habit,
    required this.currentValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressIndicator(),
        const SizedBox(width: 8),
        _buildInputSection(context),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _calculateProgress();
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[200],
        color: _getProgressColor(progress),
        strokeWidth: 4,
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    switch (habit.type) {
      case HabitType.checkbox:
        return _buildBooleanInput();
      case HabitType.numeric:
        return _buildNumericInput(context);
      case HabitType.duration:
        return _buildTimerInput();
    }
  }

  Widget _buildBooleanInput() {
    final isCompleted = currentValue == 1.0;
    return IconButton(
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? Colors.green : Colors.grey,
      ),
      onPressed: () => onValueChanged(isCompleted ? 0.0 : 1.0),
    );
  }

  Widget _buildNumericInput(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: currentValue == null || currentValue! <= 0
              ? null
              : () => onValueChanged((currentValue ?? 0) - 1),
        ),
        GestureDetector(
          onTap: () => _showNumericInputDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${currentValue?.toInt() ?? 0}/${habit.targetValue}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onValueChanged((currentValue ?? 0) + 1),
        ),
      ],
    );
  }

  Widget _buildTimerInput() {
    final minutes = ((currentValue ?? 0) / 60).floor();
    final targetMinutes = ((habit.targetValue) / 60).floor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$minutes/$targetMinutes min',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () {},
        ),
      ],
    );
  }

  void _showNumericInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter value for ${habit.title}'),
        content: TextField(
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter value',
            suffix: Text(''),
          ),
          onSubmitted: (value) {
            final newValue = double.tryParse(value);
            if (newValue != null) {
              onValueChanged(newValue);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle save
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    if (currentValue == null) return 0.0;
    return (currentValue! / habit.targetValue).clamp(0.0, 1.0);
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.grey;
  }
}
