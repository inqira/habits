import 'package:flutter/material.dart';

import 'package:habits/core/extensions/date_extension.dart';
import 'package:habits/models/category.dart';
import 'package:habits/models/habit_entry_extended.dart';
import 'package:habits/screens/habit_new/new_habit_screen.dart';
import 'package:habits/screens/home/views/todays_view/category_filter.dart';
import 'package:habits/screens/home/views/todays_view/date_selector.dart';
import 'package:habits/screens/home/views/todays_view/habit_list.dart';
import 'package:habits/screens/home/views/todays_view/todays_appbar.dart';
import 'package:habits/services/service_locator.dart';
import 'package:habits/widgets/duration_selection_widget.dart';
import 'package:habits/widgets/value_selector_widget.dart';

class TodaysView extends StatefulWidget {
  const TodaysView({super.key});

  @override
  State<TodaysView> createState() => _TodaysViewState();
}

class _TodaysViewState extends State<TodaysView> with RestorationMixin {
  final _categoryService = serviceLocator.categoryService;
  final _habitService = serviceLocator.habitService;
  final _habitEntryService = serviceLocator.habitEntryService;
  final List<DateTime> _dates = [];
  final middleIndex = 15;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  final RestorableString _selectedCategoryId = RestorableString('');

  List<HabitEntryExtended> _entries = [];

  List<Category> get categories => _entries
      .map((entry) => _categoryService.getCategoryById(entry.habit.categoryId))
      .toSet()
      .toList();

  @override
  String? get restorationId => 'todays_view';

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_selectedCategoryId, 'selected_category_id');
    _initializeDates();

    // Wait for restoration to complete before initializing entries
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _entries =
          await _habitEntryService.getEntriesForDate(_selectedDate.value);
      setState(() {});
    });
  }

  void _initializeDates([DateTime? centerDate]) {
    _dates.clear();
    final center = centerDate ?? DateTime.now();
    final startDate = center.subtract(Duration(days: middleIndex));
    for (var i = 0; i < middleIndex * 2; i++) {
      _dates.add(startDate.add(Duration(days: i)));
    }
  }

  void _refreshEntries() async {
    _entries = await _habitEntryService.getEntriesForDate(_selectedDate.value);
    setState(() {});
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isBeforeFirstHabitDay(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final normalizedFirstHabitDay =
        _normalizeDate(_habitService.firstHabitDay.value);
    return normalizedDate.isBefore(normalizedFirstHabitDay);
  }

  bool _isFutureDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final normalizedToday = _normalizeDate(DateTime.now());
    return normalizedDate.isAfter(normalizedToday);
  }

  void _handleDateSelected(DateTime newDate) async {
    if (newDate == _selectedDate.value) return;

    // Normalize the date first
    final normalizedDate = DateTime(newDate.year, newDate.month, newDate.day);

    // Prevent selecting dates before first habit day or future dates
    if (_isBeforeFirstHabitDay(normalizedDate) || _isFutureDate(normalizedDate)) return;

    if (normalizedDate.difference(_selectedDate.value).inDays.abs() >
        middleIndex) {
      // If the selected date is far, reinitialize the dates array
      _initializeDates(normalizedDate);
    }

    _selectedDate.value = normalizedDate;
    _entries = await _habitEntryService.getEntriesForDate(normalizedDate);
    setState(() {});
  }

  Future<void> _handleCycleStatus(HabitEntryExtended habitEntry) async {
    var newEntry = habitEntry.cycleStatus();
    if (newEntry.entry == null) return;
    await _habitEntryService.updateEntry(newEntry.entry);
    
    // Refresh entries for the same date without changing the selected date
    _entries = await _habitEntryService.getEntriesForDate(_selectedDate.value);
    setState(() {});
  }

  Future<void> _handleValueInput(HabitEntryExtended habitEntry) async {
    if (habitEntry.habit.type == HabitType.duration) {
      await _showDurationInputDialog(habitEntry);
    } else {
      await _showNumericInputDialog(habitEntry);
    }
  }

  Future<void> _showNumericInputDialog(HabitEntryExtended habitEntry) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => ValueSelectorWidget(
        habitName: habitEntry.habit.title,
        date: _selectedDate.value.toFormattedDateString(),
        initialValue: habitEntry.value,
        unit: habitEntry.habit.unit,
        onSubmit: (value, mode) {
          final newValue =
              mode == ValueSelectionMode.add ? habitEntry.value + value : value;
          _handleValueChanged(habitEntry, newValue.toInt());
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _showDurationInputDialog(HabitEntryExtended habitEntry) async {
    final initialDuration = Duration(seconds: habitEntry.value);

    await showModalBottomSheet(
      context: context,
      builder: (context) => DurationSelectionWidget(
        habitName: habitEntry.habit.title,
        date: _selectedDate.value.toFormattedDateString(),
        initialDuration: initialDuration,
        onSubmit: (duration, mode) {
          final seconds = duration.inSeconds;
          final newValue = mode == DurationSelectionMode.add
              ? habitEntry.value + seconds
              : seconds;
          _handleValueChanged(habitEntry, newValue.toInt());
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _handleValueChanged(HabitEntryExtended habitEntry, int value) async {
    var newEntry = habitEntry.updateValue(value);

    if (newEntry.entry == null) return;
    await _habitEntryService.updateEntry(newEntry.entry);
    
    // Refresh entries for the same date without changing the selected date
    _entries = await _habitEntryService.getEntriesForDate(_selectedDate.value);
    setState(() {});
  }

  Future<void> _navigateToNewHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewHabitScreen(),
      ),
    );

    if (result == true) {
      _refreshEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TodaysAppBar(
            selectedDate: _selectedDate.value,
            firstHabitDay: _habitService.firstHabitDay.value,
            onDateSelected: (date) {
              _handleDateSelected(date);
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            child: DateSelector(
              dates: _dates,
              selectedDate: _selectedDate.value,
              onDateSelected: _handleDateSelected,
            ),
          ),
          CategoryFilter(
            categories: categories,
            selectedCategoryId: _selectedCategoryId.value.isEmpty
                ? null
                : _selectedCategoryId.value,
            onCategorySelected: (categoryId) {
              setState(() {
                _selectedCategoryId.value = categoryId ?? '';
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HabitList(
                    habitEntries: _entries,
                    categories: categories,
                    selectedCategoryId: _selectedCategoryId.value.isEmpty
                        ? null
                        : _selectedCategoryId.value,
                    onCycleStatus: (habitEntry) {
                      _handleCycleStatus(habitEntry);
                    },
                    onValueInputRequested: (habitEntry) {
                      _handleValueInput(habitEntry);
                    },
                  ),
                  const SizedBox(
                      height: 80.0), // Bottom padding inside scroll view
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _selectedCategoryId.dispose();
    super.dispose();
  }
}
