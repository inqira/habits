import 'package:flutter/material.dart';

import 'package:habits/screens/habit_detail/tabs/calendar_tab.dart';
import 'package:habits/screens/habit_detail/tabs/details_tab.dart';
import 'package:habits/screens/habit_detail/tabs/statistics_tab.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({
    super.key,
    required this.habitId,
    this.initialTabIndex = 0,
  });

  final String habitId;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habit Details'),
          bottom: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Calendar'),
              Tab(text: 'Statistics'),
              Tab(text: 'Details'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CalendarTab(habitId: habitId),
            StatisticsTab(habitId: habitId),
            DetailsTab(habitId: habitId),
          ],
        ),
      ),
    );
  }
}
