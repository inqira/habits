import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/screens/home/views/habits_view.dart';
import 'package:habits/screens/home/views/settings_view.dart';
import 'package:habits/screens/home/views/todays_view/todays_view.dart';

class HomeScreenController {
  static final instance = HomeScreenController._();

  HomeScreenController._();

  final currentIndex = signal(0);
  final _restoredIndex = signal<int?>(null);

  void restoreState(int? index) {
    if (index != null) {
      _restoredIndex.value = index;
      currentIndex.value = index;
    }
  }

  final pages = [
    const TodaysView(),
    const HabitsView(),
    const SettingsView(),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RestorationMixin {
  final RestorableInt _currentIndex = RestorableInt(0);
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  String? get restorationId => 'home_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentIndex, 'current_index');
    HomeScreenController.instance.restoreState(_currentIndex.value);
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final controller = HomeScreenController.instance;
    controller.currentIndex.value = index;
    _currentIndex.value = index;
  }

  void _onDestinationSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _onPageChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeScreenController.instance;

    return Scaffold(
      body: Watch((context) {
        final index = controller.currentIndex.value;
        _currentIndex.value = index;
        return RestorationScope(
          restorationId: 'home_body',
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: controller.pages,
          ),
        );
      }),
      bottomNavigationBar: Watch((context) {
        return NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: _onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Ionicons.calendar_outline),
              selectedIcon: Icon(Ionicons.calendar),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Ionicons.repeat_outline),
              selectedIcon: Icon(Ionicons.repeat),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: Icon(Ionicons.settings_outline),
              selectedIcon: Icon(Ionicons.settings),
              label: 'Settings',
            ),
          ],
        );
      }),
    );
  }
}
