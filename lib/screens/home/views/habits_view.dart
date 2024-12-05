import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';

import 'package:habits/core/extensions/date_extension.dart';
import 'package:habits/screens/habit_detail/habit_detail_screen.dart';
import 'package:habits/screens/habit_new/new_habit_screen.dart';
import 'package:habits/services/habit_entry_service.dart';
import 'package:habits/services/habit_service.dart';
import 'package:habits/services/service_locator.dart';
import 'package:habits/widgets/duration_selection_widget.dart';
import 'package:habits/widgets/empty_state.dart';
import 'package:habits/widgets/value_selector_widget.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView>
    with RestorationMixin, TickerProviderStateMixin {
  HabitService get habitService => serviceLocator.habitService;
  HabitEntryService get habitEntryService => serviceLocator.habitEntryService;

  final Map<String, Map<String, HabitEntryExtended>> habitEntryMap = {};
  bool isLoadingEntries = false;

  final RestorableInt _selectedTabIndex = RestorableInt(0);
  late TabController _tabController;

  @override
  String? get restorationId => 'habits_view';

  @override
  void initState() {
    super.initState();
    registerForRestoration(_selectedTabIndex, 'selected_tab_index');

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedTabIndex.value,
    );
    _tabController.addListener(_handleTabSelection);
    _loadHabitEntries();
  }

  Future<void> _loadHabitEntries() async {
    setState(() {
      isLoadingEntries = true;
    });

    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 6));
      final endDate = now;

      for (final habit in habitService.habits.value) {
        final entries = await habitEntryService.getEntriesForHabit(
          habit.id,
          startDate,
          endDate,
        );
        habitEntryMap[habit.id.toString()] = entries;
      }
    } finally {
      setState(() {
        isLoadingEntries = false;
      });
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTabIndex, 'selected_tab_index');
    _tabController.index = _selectedTabIndex.value;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedTabIndex.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_selectedTabIndex.value != _tabController.index) {
      setState(() {
        _selectedTabIndex.value = _tabController.index;
      });
    }
  }

  Future<void> _handleValueChanged(
      HabitEntryExtended habitEntry, int value) async {
    var newEntry = habitEntry.updateValue(value);

    if (newEntry.entry == null) return;
    await habitEntryService.updateEntry(newEntry.entry);
    _loadHabitEntries();

    setState(() {});
  }

  Future<void> _showNumericInputDialog(HabitEntryExtended habitEntry) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => ValueSelectorWidget(
        habitName: habitEntry.habit.title,
        date: habitEntry.date,
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
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DurationSelectionWidget(
          habitName: habitEntry.habit.title,
          date: habitEntry.date,
          initialDuration: initialDuration,
          onSubmit: (duration, mode) {
            final seconds = duration.inSeconds;
            final newValue = mode == DurationSelectionMode.add
                ? habitEntry.value + seconds
                : seconds;
            _handleValueChanged(habitEntry, newValue);
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _handleDayTap(
      Habit habit, String dateString, HabitEntryExtended? entry) async {
    if (habit.type == HabitType.checkbox) {
      final habitEntry = entry ??
          HabitEntryExtended(
            habit: habit,
            date: dateString,
            entry: null,
          );

      var newEntry = habitEntry.cycleStatus();

      if (newEntry.entry == null) return;
      await habitEntryService.updateEntry(newEntry.entry);
      _loadHabitEntries();

      setState(() {});
    } else {
      final habitEntry = entry ??
          HabitEntryExtended(
            habit: habit,
            date: dateString,
            entry: null,
          );

      if (habit.type == HabitType.numeric) {
        await _showNumericInputDialog(habitEntry);
      } else if (habit.type == HabitType.duration) {
        await _showDurationInputDialog(habitEntry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: Watch((context) {
          final habits = habitService.habits.value;
          final activeHabits = habits.where((h) => !h.isArchived).toList();
          final archivedHabits = habits.where((h) => h.isArchived).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Active Habits Tab
              _buildHabitsList(activeHabits),

              // Archived Habits Tab
              _buildHabitsList(archivedHabits),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewHabitScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_today,
        title: 'No Habits Found',
        description: 'There are no habits in this category.',
      );
    }

    if (isLoadingEntries) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: habits.length,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _HabitCard(
            habit: habit,
            entries: habitEntryMap[habit.id.toString()] ?? {},
            onDayTap: (dateString, entry) =>
                _handleDayTap(habit, dateString, entry),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                habitService.toggleHabitArchived(habit);
              }
            },
            onArchive: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                      habit.isArchived ? 'Unarchive Habit' : 'Archive Habit'),
                  content: Text(
                    habit.isArchived
                        ? 'Are you sure you want to unarchive this habit?'
                        : 'Are you sure you want to archive this habit?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(habit.isArchived ? 'Unarchive' : 'Archive'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                habitService.toggleHabitArchived(habit);
              }
            },
            onDelete: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content: const Text(
                    'Are you sure you want to delete this habit? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                habitService.deleteHabit(habit.id);
              }
            },
          ),
        );
      },
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.entries,
    required this.onDismissed,
    required this.onDayTap,
    this.onArchive,
    this.onDelete,
  });

  final Habit habit;
  final Map<String, HabitEntryExtended> entries;
  final Function(DismissDirection) onDismissed;
  final Function(String dateString, HabitEntryExtended? entry) onDayTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  String _getFrequencyText(Habit habit) {
    String text = switch (habit.frequencyType) {
      FrequencyType.daily => 'Every day',
      FrequencyType.weekly => habit.targetDays != null
          ? '${habit.targetDays} days per week'
          : habit.selectedDays.isEmpty
              ? 'Every week'
              : 'On ${habit.selectedDays.map((d) => switch (d) {
                    1 => 'Mon',
                    2 => 'Tue',
                    3 => 'Wed',
                    4 => 'Thu',
                    5 => 'Fri',
                    6 => 'Sat',
                    7 => 'Sun',
                    _ => ''
                  }).join(', ')}',
      FrequencyType.monthly => habit.targetDays != null
          ? '${habit.targetDays} days per month'
          : habit.selectedDays.isEmpty
              ? 'Every month'
              : 'On day ${habit.selectedDays.join(', ')} of each month',
      _ => 'Unknown',
    };
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final category =
        serviceLocator.categoryService.getCategoryById(habit.categoryId);

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              habit.isArchived ? 'Unarchive Habit?' : 'Archive Habit?',
            ),
            content: Text(
              habit.isArchived
                  ? 'Are you sure you want to unarchive this habit?'
                  : 'Are you sure you want to archive this habit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(habit.isArchived ? 'Unarchive' : 'Archive'),
              ),
            ],
          ),
        );
      },
      background: Container(
        color: habit.isArchived
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          habit.isArchived ? Icons.unarchive : Icons.archive,
          color: habit.isArchived
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      ),
      onDismissed: onDismissed,
      child: Card.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: Row(
                  children: [
                    Text(
                      habit.title,
                      style: habit.isArchived
                          ? Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(decoration: TextDecoration.lineThrough)
                          : Theme.of(context).textTheme.titleMedium,
                    ),
                    if (habit.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Tooltip(
                          message: habit.description!,
                          child: const Icon(
                            Icons.info_outline,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _getFrequencyText(habit),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 10),
                  ),
                ),
                leading: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(category.color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) => SizedBox(
                      width: 32,
                      child: Text(
                        switch (index) {
                          0 => 'M',
                          1 => 'T',
                          2 => 'W',
                          3 => 'T',
                          4 => 'F',
                          5 => 'S',
                          6 => 'S',
                          _ => '',
                        },
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (index) {
                      final now = DateTime.now();
                      final day =
                          now.subtract(Duration(days: now.weekday - 1 - index));
                      final isAvailable = habit.availableAtDate(day);
                      final dateString = day.toShortDateString();
                      final entry = entries[dateString];

                      final isSucceeded =
                          entry?.status == HabitEntryStatus.success;
                      final isFailed = entry?.status == HabitEntryStatus.failed;

                      final borderColor = isSucceeded
                          ? Theme.of(context).colorScheme.primary
                          : isFailed
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outlineVariant;

                      final backgroundColor = !isAvailable
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : isSucceeded
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.4)
                              : isFailed
                                  ? Theme.of(context)
                                      .colorScheme
                                      .errorContainer
                                      .withOpacity(0.4)
                                  : null;

                      final borderWidth = entry?.entry != null ? 2.0 : 1.5;

                      return GestureDetector(
                        onTap: !isAvailable
                            ? null
                            : () => onDayTap(dateString, entry),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape:
                                isFailed ? BoxShape.rectangle : BoxShape.circle,
                            border: Border.all(
                              color: borderColor,
                              width: borderWidth,
                            ),
                            borderRadius:
                                isFailed ? BorderRadius.circular(8) : null,
                            color: backgroundColor,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: 32,
                            height: 32,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: entry?.entry != null ? 1.0 : 0.8,
                              child: Center(
                                child: Text(
                                  day.day.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: !isAvailable
                                            ? Theme.of(context)
                                                .colorScheme
                                                .outline
                                            : null,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habitId: habit.id.toString(),
                            initialTabIndex: 0,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Calendar',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habitId: habit.id.toString(),
                            initialTabIndex: 1,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Statistics',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habitId: habit.id.toString(),
                            initialTabIndex: 2,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Details',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        habit.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading:
                                    const Icon(Icons.calendar_month_outlined),
                                title: const Text('Calendar'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HabitDetailScreen(
                                        habitId: habit.id.toString(),
                                        initialTabIndex: 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.bar_chart_outlined),
                                title: const Text('Statistics'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HabitDetailScreen(
                                        habitId: habit.id.toString(),
                                        initialTabIndex: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit_outlined),
                                title: const Text('Details & Edit'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HabitDetailScreen(
                                        habitId: habit.id.toString(),
                                        initialTabIndex: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(
                                  habit.isArchived
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(
                                  habit.isArchived ? 'Unarchive' : 'Archive',
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  onArchive?.call();
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                title: const Text('Delete'),
                                textColor: Theme.of(context).colorScheme.error,
                                onTap: () {
                                  Navigator.pop(context);
                                  onDelete?.call();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    tooltip: 'More',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
