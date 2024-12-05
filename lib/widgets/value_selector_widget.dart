import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ValueSelectionMode {
  replace,
  add,
}

class ValueSelectorWidget extends StatefulWidget {
  final String habitName;
  final String date;
  final int initialValue;
  final String? unit;
  final Function(int value, ValueSelectionMode mode) onSubmit;
  final VoidCallback onCancel;

  const ValueSelectorWidget({
    super.key,
    required this.habitName,
    required this.date,
    required this.onSubmit,
    required this.onCancel,
    required this.initialValue,
    this.unit,
  });

  @override
  State<ValueSelectorWidget> createState() => _ValueSelectorWidgetState();
}

class _ValueSelectorWidgetState extends State<ValueSelectorWidget> {
  late final TextEditingController _controller;
  ValueSelectionMode _mode = ValueSelectionMode.replace;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _currentValue++;
      _controller.text = _currentValue.toString();
    });
  }

  void _decrement() {
    if (_currentValue > 0) {
      setState(() {
        _currentValue--;
        _controller.text = _currentValue.toString();
      });
    }
  }

  void _updateValue(String value) {
    final newValue = int.tryParse(value) ?? 0;
    setState(() {
      _currentValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
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

          // Value Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement Button
              IconButton.outlined(
                onPressed: _decrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),

              // Value Input
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: _updateValue,
                    ),
                  ),
                  if (widget.unit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.unit!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 16),

              // Increment Button
              IconButton.outlined(
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mode Selection
          SegmentedButton<ValueSelectionMode>(
            segments: const [
              ButtonSegment(
                value: ValueSelectionMode.replace,
                label: Text('Replace'),
                icon: Icon(Icons.sync),
              ),
              ButtonSegment(
                value: ValueSelectionMode.add,
                label: Text('Add'),
                icon: Icon(Icons.add),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (Set<ValueSelectionMode> newSelection) {
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
                onPressed: () => widget.onSubmit(_currentValue, _mode),
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
