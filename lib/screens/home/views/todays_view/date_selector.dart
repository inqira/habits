import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:habits/services/service_locator.dart';

class DateSelector extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _slideController;
  final _slideTween = Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: const Offset(0.0, 0.0),
  );

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollToSelectedDate();
  }

  @override
  void didUpdateWidget(DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _updateAnimation(oldWidget.selectedDate);
      _scrollToSelectedDate();
    }
  }

  void _updateAnimation(DateTime oldDate) {
    final slideLeft = widget.selectedDate.isAfter(oldDate);
    _slideTween.begin = Offset(slideLeft ? 1.0 : -1.0, 0.0);
    _slideTween.end = const Offset(0.0, 0.0);
    _slideController.forward(from: 0);
  }

  void _scrollToSelectedDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final itemWidth = 80.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final selectedIndex = widget.dates.indexWhere(
        (date) => DateUtils.isSameDay(date, widget.selectedDate),
      );

      if (selectedIndex == -1) return;

      final targetOffset =
          (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitService = serviceLocator.habitService;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
          final isFutureDate = date.isAfter(DateTime.now());
          final isDisabled =
              date.isBefore(habitService.firstHabitDay.value) || isFutureDate;

          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: InkWell(
              onTap: isDisabled ? null : () => widget.onDateSelected(date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isDisabled
                          ? Theme.of(context).disabledColor
                          : isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 24,
                      color: isDisabled
                          ? Theme.of(context).disabledColor
                          : isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
