import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:habits/models/habit.dart';

class FrequencyStep extends StatefulWidget {
  final FrequencyType frequencyType;
  final int? targetDays;
  final List<int> selectedDays;
  final ValueChanged<FrequencyType> onFrequencyTypeChanged;
  final ValueChanged<int?> onTargetDaysChanged;
  final ValueChanged<List<int>> onSelectedDaysChanged;
  final Widget Function<T>({
    required T value,
    required T groupValue,
    required String title,
    required IconData icon,
    String? subtitle,
    required ValueChanged<T> onChanged,
  }) buildSelectionTile;
  final InputDecoration Function({required String labelText, String? hintText})
      buildInputDecoration;

  const FrequencyStep({
    super.key,
    required this.frequencyType,
    required this.targetDays,
    required this.selectedDays,
    required this.onFrequencyTypeChanged,
    required this.onTargetDaysChanged,
    required this.onSelectedDaysChanged,
    required this.buildSelectionTile,
    required this.buildInputDecoration,
  });

  @override
  State<FrequencyStep> createState() => _FrequencyStepState();
}

class _FrequencyStepState extends State<FrequencyStep> {
  late FixedExtentScrollController _weeklyController;
  late FixedExtentScrollController _monthlyController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(FrequencyStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetDays != oldWidget.targetDays) {
      _initControllers();
    }
  }

  void _initControllers() {
    _weeklyController = FixedExtentScrollController(
      initialItem: widget.targetDays != null ? widget.targetDays! : 0,
    );
    _monthlyController = FixedExtentScrollController(
      initialItem: widget.targetDays != null ? widget.targetDays! : 0,
    );
  }

  @override
  void dispose() {
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you want to do this?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        widget.buildSelectionTile(
          value: FrequencyType.daily,
          groupValue: widget.frequencyType,
          title: 'Daily',
          subtitle: 'Every day',
          icon: Icons.calendar_today,
          onChanged: widget.onFrequencyTypeChanged,
        ),
        const SizedBox(height: 8),
        widget.buildSelectionTile(
          value: FrequencyType.weekly,
          groupValue: widget.frequencyType,
          title: 'Weekly',
          subtitle: 'Select days or target number per week',
          icon: Icons.calendar_view_week,
          onChanged: widget.onFrequencyTypeChanged,
        ),
        if (widget.frequencyType == FrequencyType.weekly) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'Select day count per week:',
                          style: Theme.of(context).textTheme.bodyLarge,
                          minFontSize: 10,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 100,
                        width: 50,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CupertinoPicker(
                          itemExtent: 32,
                          squeeze: 1.0,
                          magnification: 1.0,
                          useMagnifier: false,
                          scrollController: _weeklyController,
                          onSelectedItemChanged: (index) {
                            final number = index == 0 ? null : index;
                            widget.onTargetDaysChanged(number);
                            widget.onSelectedDaysChanged([]);
                          },
                          children: [
                            Center(
                              child: Text(
                                '-',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            ...List<Widget>.generate(
                              7,
                              (index) => Center(
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OR Select days of the week',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 1; i <= 7; i++)
                        FilterChip(
                          label: Text(_getWeekdayName(i)),
                          selected: widget.selectedDays.contains(i),
                          onSelected: (selected) {
                            final newSelectedDays =
                                List<int>.from(widget.selectedDays);
                            if (selected) {
                              newSelectedDays.add(i);
                            } else {
                              newSelectedDays.remove(i);
                            }
                            widget.onSelectedDaysChanged(newSelectedDays);
                            widget.onTargetDaysChanged(null);
                            _weeklyController.animateToItem(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        widget.buildSelectionTile(
          value: FrequencyType.monthly,
          groupValue: widget.frequencyType,
          title: 'Monthly',
          subtitle: 'Select days or target number per month',
          icon: Icons.calendar_month,
          onChanged: widget.onFrequencyTypeChanged,
        ),
        if (widget.frequencyType == FrequencyType.monthly) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'Choose number of days per month:',
                          style: Theme.of(context).textTheme.bodyLarge,
                          minFontSize: 10,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 100,
                        width: 50,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CupertinoPicker(
                          itemExtent: 32,
                          squeeze: 1.0,
                          magnification: 1.0,
                          useMagnifier: false,
                          scrollController: _monthlyController,
                          onSelectedItemChanged: (index) {
                            final number = index == 0 ? null : index;
                            widget.onTargetDaysChanged(number);
                            widget.onSelectedDaysChanged([]);
                          },
                          children: [
                            Center(
                              child: Text(
                                '-',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            ...List<Widget>.generate(
                              31,
                              (index) => Center(
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OR Select days of the month',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        return InkWell(
                          onTap: () {
                            final newSelectedDays =
                                List<int>.from(widget.selectedDays);
                            if (widget.selectedDays.contains(day)) {
                              newSelectedDays.remove(day);
                            } else {
                              newSelectedDays.add(day);
                            }
                            widget.onSelectedDaysChanged(newSelectedDays);
                            widget.onTargetDaysChanged(null);
                            _monthlyController.animateToItem(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.selectedDays.contains(day)
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.selectedDays.contains(day)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: widget.selectedDays.contains(day)
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getWeekdayName(int day) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[day - 1];
  }
}
