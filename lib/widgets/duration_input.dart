import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DurationInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final InputDecoration Function({
    required String labelText,
    String? hintText,
  }) buildInputDecoration;

  const DurationInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.buildInputDecoration,
  });

  @override
  State<DurationInput> createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    final value = widget.controller.text;
    if (value.isEmpty) {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      return;
    }

    final parts = value.split(':');
    if (parts.length == 3) {
      _hours = int.tryParse(parts[0]) ?? 0;
      _minutes = int.tryParse(parts[1]) ?? 0;
      _seconds = int.tryParse(parts[2]) ?? 0;
    } else {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    }
  }

  void _showDialog() {
    _parseInitialValue();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Hours',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              onSelectedItemChanged: (index) => _hours = index,
                              scrollController: FixedExtentScrollController(
                                initialItem: _hours,
                              ),
                              children: List<Widget>.generate(24, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Minutes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              onSelectedItemChanged: (index) =>
                                  _minutes = index,
                              scrollController: FixedExtentScrollController(
                                initialItem: _minutes,
                              ),
                              children: List<Widget>.generate(60, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Seconds',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              onSelectedItemChanged: (index) =>
                                  _seconds = index,
                              scrollController: FixedExtentScrollController(
                                initialItem: _seconds,
                              ),
                              children: List<Widget>.generate(60, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final formattedTime =
                          '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';
                      widget.controller.text = formattedTime;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: widget.buildInputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      onTap: _showDialog,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a duration';
        }
        return null;
      },
    );
  }
}
