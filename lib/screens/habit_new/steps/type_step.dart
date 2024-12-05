import 'package:flutter/material.dart';

import 'package:habits/models/habit.dart';
import 'package:habits/widgets/duration_input.dart';
import 'package:habits/widgets/numeric_input.dart';

class TypeStep extends StatefulWidget {
  final HabitType type;
  final ValueChanged<HabitType> onTypeChanged;
  final TextEditingController? valueController;
  final TextEditingController? unitController;
  final TargetCompletionType targetCompletionType;
  final ValueChanged<TargetCompletionType> onTargetCompletionTypeChanged;
  final Widget Function<T>({
    required T value,
    required T groupValue,
    required String title,
    required IconData icon,
    String? subtitle,
    required ValueChanged<T> onChanged,
  }) buildSelectionTile;
  final InputDecoration Function({
    required String labelText,
    String? hintText,
  }) buildInputDecoration;

  const TypeStep({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.buildSelectionTile,
    required this.buildInputDecoration,
    required this.targetCompletionType,
    required this.onTargetCompletionTypeChanged,
    this.valueController,
    this.unitController,
  });

  @override
  State<TypeStep> createState() => _TypeStepState();
}

class _TypeStepState extends State<TypeStep> {
  void _handleTypeChange(HabitType newType) {
    widget.valueController?.clear();
    widget.unitController?.clear();
    widget.onTypeChanged(newType);
  }

  @override
  void initState() {
    super.initState();
    if (widget.unitController != null) {
      widget.unitController!.addListener(_onUnitChanged);
    }
  }

  void _onUnitChanged() {
    if (mounted) {
      setState(() {}); // Only rebuild if still mounted
    }
  }

  @override
  void dispose() {
    if (widget.unitController != null) {
      widget.unitController!.removeListener(_onUnitChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of habit is this?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        widget.buildSelectionTile(
          value: HabitType.checkbox,
          groupValue: widget.type,
          title: 'Yes/No',
          subtitle: 'Simple checkbox to mark as done',
          icon: Icons.check_box_outlined,
          onChanged: _handleTypeChange,
        ),
        const SizedBox(height: 8),
        widget.buildSelectionTile(
          value: HabitType.numeric,
          groupValue: widget.type,
          title: 'Numeric',
          subtitle: 'Track a number (e.g., steps, glasses of water)',
          icon: Icons.numbers,
          onChanged: _handleTypeChange,
        ),
        const SizedBox(height: 8),
        widget.buildSelectionTile(
          value: HabitType.duration,
          groupValue: widget.type,
          title: 'Duration',
          subtitle: 'Track time spent (e.g., meditation, exercise)',
          icon: Icons.timer,
          onChanged: _handleTypeChange,
        ),
        if ((widget.type == HabitType.numeric ||
                widget.type == HabitType.duration) &&
            widget.valueController != null &&
            widget.unitController != null) ...[
          const SizedBox(height: 16),
          Text(
            'How do you want to track your target?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card.outlined(
                  child: InkWell(
                    onTap: () => widget.onTargetCompletionTypeChanged(
                        TargetCompletionType.atLeast),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.targetCompletionType ==
                                TargetCompletionType.atLeast
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            size: 20,
                            color: widget.targetCompletionType ==
                                    TargetCompletionType.atLeast
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'At Least',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.targetCompletionType ==
                                      TargetCompletionType.atLeast
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: widget.targetCompletionType ==
                                      TargetCompletionType.atLeast
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card.outlined(
                  child: InkWell(
                    onTap: () => widget.onTargetCompletionTypeChanged(
                        TargetCompletionType.exactly),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.targetCompletionType ==
                                TargetCompletionType.exactly
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drag_handle,
                            size: 20,
                            color: widget.targetCompletionType ==
                                    TargetCompletionType.exactly
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Exactly',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.targetCompletionType ==
                                      TargetCompletionType.exactly
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: widget.targetCompletionType ==
                                      TargetCompletionType.exactly
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card.outlined(
                  child: InkWell(
                    onTap: () => widget.onTargetCompletionTypeChanged(
                        TargetCompletionType.atMost),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.targetCompletionType ==
                                TargetCompletionType.atMost
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 20,
                            color: widget.targetCompletionType ==
                                    TargetCompletionType.atMost
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'At Most',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.targetCompletionType ==
                                      TargetCompletionType.atMost
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: widget.targetCompletionType ==
                                      TargetCompletionType.atMost
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.type == HabitType.numeric)
            NumericInput(
              controller: widget.valueController!,
              label:
                  'Target Value${widget.unitController!.text.isNotEmpty ? ' (${widget.unitController!.text})' : ''}',
              hint: 'e.g. 10000',
              buildInputDecoration: widget.buildInputDecoration,
            )
          else if (widget.type == HabitType.duration)
            DurationInput(
              controller: widget.valueController!,
              label: 'Target Duration',
              hint: 'e.g. 30:00',
              buildInputDecoration: widget.buildInputDecoration,
            ),
          if (widget.type == HabitType.numeric) ...[
            const SizedBox(height: 16),
            TextField(
              controller: widget.unitController,
              decoration: widget.buildInputDecoration(
                labelText: 'Unit (optional)',
                hintText: 'e.g. steps, glasses',
              ),
            ),
          ],
        ],
      ],
    );
  }
}
