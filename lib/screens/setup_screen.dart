import 'dart:async';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/core/utils/id_generator.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/screens/home/home_screen.dart';
import 'package:habits/services/service_locator.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final settingsService = serviceLocator.settingsService;
  final habitService = serviceLocator.habitService;
  final categoryService = serviceLocator.categoryService;
  final nameController = TextEditingController();
  late Timer timer;
  final currentTime = signal('');
  final nameError = signal<String?>(null);
  String? name;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _updateTime(); // Update immediately
  }

  Future<void> _initializeDefaultHabits() async {
    if (habitService.habits.value.isEmpty) {
      final healthCategoryId = categoryService.findByName('Health').id;
      final studyCategoryId = categoryService.findByName('Study').id;
      final sportsCategoryId = categoryService.findByName('Sports').id;
      final meditationCategoryId = categoryService.findByName('Meditation').id;
      final quitBadHabitCategoryId =
          categoryService.findByName('Quit Bad Habit').id;

      final id1 = await IdGenerator().generate();
      await habitService.addHabit(
        Habit(
          id: id1,
          title: 'Daily Exercise',
          description: 'Stay healthy with daily physical activity',
          categoryId: sportsCategoryId,
          type: HabitType.duration,
          frequencyType: FrequencyType.daily,
          selectedDays: [],
          targetDays: 0,
          targetValue: 30,
          period: PeriodOfDay.anytime,
          startDate: DateTime.now().subtract(Duration(days: 3)),
          createdAt: DateTime.now(),
          isArchived: false,
          targetCompletionType: TargetCompletionType.atLeast,
        ),
      );

      final id2 = await IdGenerator().generate();
      await habitService.addHabit(
        Habit(
          id: id2,
          title: 'Read Books',
          description: 'Read to expand knowledge and imagination',
          categoryId: studyCategoryId,
          type: HabitType.numeric,
          frequencyType: FrequencyType.daily,
          selectedDays: [],
          targetDays: 0,
          targetValue: 30,
          period: PeriodOfDay.anytime,
          startDate: DateTime.now().subtract(Duration(days: 3)),
          unit: 'pages',
          createdAt: DateTime.now(),
          isArchived: false,
        ),
      );

      final id3 = await IdGenerator().generate();
      await habitService.addHabit(
        Habit(
          id: id3,
          title: 'Drink Water',
          description: 'Stay hydrated throughout the day',
          categoryId: healthCategoryId,
          type: HabitType.numeric,
          frequencyType: FrequencyType.daily,
          selectedDays: [],
          targetDays: 0,
          targetValue: 8,
          period: PeriodOfDay.anytime,
          startDate: DateTime.now().subtract(Duration(days: 3)),
          unit: 'glasses',
          createdAt: DateTime.now(),
          isArchived: false,
        ),
      );

      final id4 = await IdGenerator().generate();
      await habitService.addHabit(
        Habit(
          id: id4,
          title: 'Morning Meditation',
          description: 'Start your day with mindfulness',
          categoryId: meditationCategoryId,
          type: HabitType.checkbox,
          frequencyType: FrequencyType.daily,
          selectedDays: [],
          targetDays: 0,
          period: PeriodOfDay.morning,
          startDate: DateTime.now().subtract(Duration(days: 3)),
          createdAt: DateTime.now(),
          isArchived: false,
        ),
      );

      final id5 = await IdGenerator().generate();
      await habitService.addHabit(
        Habit(
          id: id5,
          title: 'Social Media Limit',
          description: 'Reduce time spent on social media',
          categoryId: quitBadHabitCategoryId,
          type: HabitType.duration,
          targetValue: 30 * 60,
          frequencyType: FrequencyType.daily,
          targetCompletionType: TargetCompletionType.atMost,
          selectedDays: [],
          targetDays: 0,
          period: PeriodOfDay.anytime,
          startDate: DateTime.now().subtract(Duration(days: 3)),
          createdAt: DateTime.now(),
          isArchived: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    nameError.value =
        nameController.text.trim().isEmpty ? 'Name is required' : null;
  }

  void _updateTime() {
    final now = DateTime.now();
    final is24Hour = settingsService.settings.is24HourFormat.value;
    final hour =
        is24Hour ? now.hour : (now.hour > 12 ? now.hour - 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';

    currentTime.value = is24Hour
        ? '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
        : '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }

  void _showEditAvatarDialog(BuildContext context) {
    var theme = ThemeData.light().copyWith();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AutoSizeText(
                      maxLines: 1,
                      'Customize Your Avatar',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: FluttermojiCircleAvatar(
                    radius: 48,
                  ),
                ),
                const SizedBox(height: 24),
                FluttermojiCustomizer(
                  scaffoldWidth: MediaQuery.of(context).size.width,
                  autosave: true,
                  theme: FluttermojiThemeData(
                    primaryBgColor: theme.colorScheme.primaryContainer,
                    secondaryBgColor: theme.colorScheme.tertiaryContainer,
                    iconColor: theme.colorScheme.primary,
                    selectedIconColor: theme.colorScheme.onPrimaryContainer,
                    unselectedIconColor: theme.colorScheme.onSecondaryContainer,
                    labelTextStyle: theme.textTheme.bodyMedium!,
                    selectedTileDecoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    unselectedTileDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tilePadding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeSetup() async {
    if (nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize categories first
      await serviceLocator.categoryService.initializeDefaultCategories();

      // Initialize default habits after categories are created
      await _initializeDefaultHabits();

      // Save user settings
      settingsService.settings.updateSettings(
        newName: nameController.text.trim(),
      );
      await settingsService.saveSettings();

      if (!mounted) return;

      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to complete setup. Please try again.';
      });
      debugPrint('Error during setup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.dependOnInheritedWidgetOfExactType();
      }
    });

    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Avatar Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          FluttermojiCircleAvatar(
                            radius: 64,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _showEditAvatarDialog(context),
                            icon: const Icon(Icons.edit),
                            label: const Text('Customize Avatar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Welcome to Let\'s Habit! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Let\'s personalize your experience',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Input Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Watch((context) {
                        return TextField(
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                            _validateName();
                          },
                          decoration: InputDecoration(
                            labelText: 'What\'s Your Name',
                            hintText: 'Enter your name',
                            filled: true,
                            errorText: nameError.value ?? _errorMessage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Time Display Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Watch((context) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Time Display - ${currentTime.value}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Watch((context) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: false,
                                    label: Text('12-hour'),
                                    icon: Icon(Icons.schedule),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    label: Text('24-hour'),
                                    icon: Icon(Icons.schedule),
                                  ),
                                ],
                                selected: {
                                  settingsService.settings.is24HourFormat.value
                                },
                                onSelectionChanged: (Set<bool> newSelection) {
                                  settingsService.settings.updateSettings(
                                    newIs24HourFormat: newSelection.first,
                                  );
                                  settingsService.saveSettings();
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Theme Color Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your theme',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<FlexScheme>(
                            value: settingsService.settings.themeScheme.value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            items: FlexScheme.values.map((scheme) {
                              final themePrimaryColor =
                                  FlexThemeData.light(scheme: scheme)
                                      .primaryColor;
                              return DropdownMenuItem(
                                value: scheme,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: themePrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      scheme.name
                                          .replaceAllMapped(
                                            RegExp(r'([A-Z])'),
                                            (match) => ' ${match[1]}',
                                          )
                                          .trim()
                                          .toLowerCase()
                                          .split(' ')
                                          .map((word) =>
                                              word[0].toUpperCase() +
                                              word.substring(1))
                                          .join(' '),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (scheme) {
                              if (scheme != null) {
                                settingsService.settings.updateSettings(
                                  newThemeScheme: scheme,
                                );
                                settingsService.saveSettings();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a color scheme that matches your style',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Theme Mode Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Appearance',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Select your preferred theme mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Watch((context) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text('Light'),
                                    icon: Icon(Icons.light_mode),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text('Dark'),
                                    icon: Icon(Icons.dark_mode),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text('System'),
                                    icon: Icon(Icons.settings_suggest),
                                  ),
                                ],
                                selected: {
                                  settingsService.settings.themeMode.value
                                },
                                onSelectionChanged:
                                    (Set<ThemeMode> newSelection) {
                                  settingsService.settings.updateSettings(
                                    newThemeMode: newSelection.first,
                                  );
                                  settingsService.saveSettings();
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Save Button
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Watch((context) {
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isLoading ||
                                    name?.trim().isEmpty != false ||
                                    nameError.value != null ||
                                    _errorMessage != null
                                ? null
                                : _completeSetup,
                            icon: const Icon(Icons.check),
                            label: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Preferences'),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
