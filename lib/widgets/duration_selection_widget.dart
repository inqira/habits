import 'package:flutter/material.dart';

enum DurationSelectionMode {
  replace,
  add,
}

class DurationSelectionWidget extends StatefulWidget {
  final String habitName;
  final String date;
  final Duration? initialDuration;
  final Function(Duration duration, DurationSelectionMode mode) onSubmit;
  final VoidCallback onCancel;

  const DurationSelectionWidget({
    super.key,
    required this.habitName,
    required this.date,
    required this.onSubmit,
    required this.onCancel,
    this.initialDuration,
  });

  @override
  State<DurationSelectionWidget> createState() =>
      _DurationSelectionWidgetState();
}

class _DurationSelectionWidgetState extends State<DurationSelectionWidget> {
  late Duration _selectedDuration;
  DurationSelectionMode _mode = DurationSelectionMode.replace;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration ?? const Duration();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _selectedDuration.inHours;
    final minutes = _selectedDuration.inMinutes.remainder(60);
    final seconds = _selectedDuration.inSeconds.remainder(60);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            widget.habitName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Duration Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _selectedDuration += const Duration(hours: 1);
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hours.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: hours > 0
                        ? () {
                            setState(() {
                              _selectedDuration -= const Duration(hours: 1);
                            });
                          }
                        : null,
                  ),
                  Text(
                    'Hours',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(':', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),

              // Minutes
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _selectedDuration += const Duration(minutes: 1);
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      minutes.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: minutes > 0
                        ? () {
                            setState(() {
                              _selectedDuration -= const Duration(minutes: 1);
                            });
                          }
                        : null,
                  ),
                  Text(
                    'Minutes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(':', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),

              // Seconds
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _selectedDuration += const Duration(seconds: 1);
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      seconds.toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: seconds > 0
                        ? () {
                            setState(() {
                              _selectedDuration -= const Duration(seconds: 1);
                            });
                          }
                        : null,
                  ),
                  Text(
                    'Seconds',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mode Selection
          SegmentedButton<DurationSelectionMode>(
            segments: const [
              ButtonSegment(
                value: DurationSelectionMode.replace,
                label: Text('Replace'),
                icon: Icon(Icons.sync),
              ),
              ButtonSegment(
                value: DurationSelectionMode.add,
                label: Text('Add'),
                icon: Icon(Icons.add),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<DurationSelectionMode> newSelection) {
              setState(() {
                _mode = newSelection.first;
              });
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => widget.onSubmit(_selectedDuration, _mode),
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
