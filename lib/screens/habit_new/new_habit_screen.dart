import 'package:flutter/material.dart';

import 'package:habits/core/utils/id_generator.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/screens/habit_new/steps/steps.dart';
import 'package:habits/services/service_locator.dart';

class NewHabitScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialCategoryId;
  final HabitType? initialType;
  final String? initialTargetValue;
  final FrequencyType? initialFrequencyType;
  final Set<int>? initialSelectedDays;
  final int? initialTargetDays;
  final PeriodOfDay? initialPeriod;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color? initialColor;
  final TargetCompletionType? initialTargetCompletionType;
  final String? initialUnit;

  const NewHabitScreen({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialCategoryId,
    this.initialType,
    this.initialTargetValue,
    this.initialFrequencyType,
    this.initialSelectedDays,
    this.initialTargetDays,
    this.initialPeriod,
    this.initialStartDate,
    this.initialEndDate,
    this.initialColor,
    this.initialTargetCompletionType,
    this.initialUnit,
  });

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryService = serviceLocator.categoryService;

  String _categoryId = '';
  HabitType _type = HabitType.checkbox;
  FrequencyType _frequencyType = FrequencyType.daily;
  PeriodOfDay _period = PeriodOfDay.anytime;
  TargetCompletionType _targetCompletionType = TargetCompletionType.atLeast;
  Set<int> _selectedDays = <int>{};
  int? _targetDays;
  Color? _color;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _isLoading = false;
  int _currentStep = 0;

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignLabelWithHint: true,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    if (widget.initialCategoryId != null) {
      _categoryId = widget.initialCategoryId!;
    }
    if (widget.initialType != null) {
      _type = widget.initialType!;
    }
    if (widget.initialTargetValue != null) {
      _valueController.text = widget.initialTargetValue!;
    }
    if (widget.initialFrequencyType != null) {
      _frequencyType = widget.initialFrequencyType!;
    }
    if (widget.initialSelectedDays != null) {
      _selectedDays = widget.initialSelectedDays!;
    }
    if (widget.initialTargetDays != null) {
      _targetDays = widget.initialTargetDays!;
    }
    if (widget.initialPeriod != null) {
      _period = widget.initialPeriod!;
    }
    if (widget.initialStartDate != null) {
      _startDate = widget.initialStartDate!;
    }
    if (widget.initialEndDate != null) {
      _endDate = widget.initialEndDate!;
    }
    if (widget.initialColor != null) {
      _color = widget.initialColor!;
    }
    if (widget.initialTargetCompletionType != null) {
      _targetCompletionType = widget.initialTargetCompletionType!;
    }
    if (widget.initialUnit != null) {
      _unitController.text = widget.initialUnit!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final habitService = serviceLocator.habitService;

      final targetValue = int.tryParse(_valueController.text) ?? 1;

      final id = await IdGenerator().generate();
      final habit = Habit(
        id: id,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _categoryId,
        type: _type,
        frequencyType: _frequencyType,
        selectedDays: _selectedDays.toList(),
        targetDays: _targetDays,
        targetValue: targetValue,
        period: _period,
        startDate: _startDate,
        endDate: _endDate,
        targetCompletionType: _targetCompletionType,
        unit: _type == HabitType.numeric && _unitController.text.isNotEmpty
            ? _unitController.text
            : null,
        createdAt: DateTime.now(),
        isArchived: false,
      );

      await habitService.addHabit(habit);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _saveHabit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info Step
        if (!_formKey.currentState!.validate()) return false;
        if (_categoryId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')),
          );
          return false;
        }
        return true;

      case 1: // Type Step
        if (_type == HabitType.numeric || _type == HabitType.duration) {
          if (_valueController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a target value')),
            );
            return false;
          }
        }
        return true;

      case 2: // Frequency Step
        if (_frequencyType == FrequencyType.weekly) {
          if (_targetDays == null && _selectedDays.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please select either target days per week or specific days'),
              ),
            );
            return false;
          }
        } else if (_frequencyType == FrequencyType.monthly) {
          if (_targetDays == null && _selectedDays.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please select either target days per month or specific dates'),
              ),
            );
            return false;
          }
        }
        return true;

      case 3: // Schedule Step
        return true;

      case 4: // Settings Step
        return true;

      case 5: // Review Step
        return true;

      default:
        return true;
    }
  }

  Widget _buildBasicInfoStep() {
    final ids = _categoryService.categoryIds.value;
    final categories =
        ids.map((id) => _categoryService.getCategoryById(id)).toList();

    return BasicInfoStep(
      titleController: _titleController,
      descriptionController: _descriptionController,
      buildInputDecoration: _buildInputDecoration,
      categories: categories,
      selectedCategoryId: _categoryId,
      onCategoryChanged: (categoryId) {
        if (categoryId != null) {
          setState(() => _categoryId = categoryId);
        }
      },
    );
  }

  Widget _buildTypeStep() {
    return TypeStep(
      type: _type,
      onTypeChanged: (type) => setState(() => _type = type),
      valueController: _valueController,
      unitController: _unitController,
      targetCompletionType: _targetCompletionType,
      onTargetCompletionTypeChanged: (type) =>
          setState(() => _targetCompletionType = type),
      buildSelectionTile: _buildSelectionTile,
      buildInputDecoration: _buildInputDecoration,
    );
  }

  Widget _buildFrequencyStep() {
    return FrequencyStep(
      frequencyType: _frequencyType,
      targetDays: _targetDays,
      selectedDays: _selectedDays.toList(),
      onFrequencyTypeChanged: (value) {
        setState(() {
          _frequencyType = value;
          // Reset selections when frequency type changes
          _selectedDays.clear();
          _targetDays = null;
        });
      },
      onTargetDaysChanged: (value) => setState(() => _targetDays = value),
      onSelectedDaysChanged: (value) =>
          setState(() => _selectedDays = value.toSet()),
      buildSelectionTile: _buildSelectionTile,
      buildInputDecoration: _buildInputDecoration,
    );
  }

  Widget _buildScheduleStep() {
    return ScheduleStep(
      period: _period,
      onPeriodChanged: (value) => setState(() => _period = value),
      buildSelectionTile: _buildSelectionTile,
    );
  }

  Widget _buildSettingsStep() {
    return SettingsStep(
      startDate: _startDate,
      endDate: _endDate,
      onStartDateChanged: (value) => setState(() => _startDate = value),
      onEndDateChanged: (value) => setState(() => _endDate = value),
    );
  }

  Widget _buildReviewStep() {
    if (_categoryId.isEmpty) {
      return const Center(child: Text('Please select a category first'));
    }

    final category = _categoryService.getCategoryById(_categoryId);

    final targetValue =
        _type == HabitType.numeric && _valueController.text.isNotEmpty
            ? int.tryParse(_valueController.text)
            : null;

    return ReviewStep(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      category: category,
      type: _type,
      targetValue: targetValue,
      frequencyType: _frequencyType,
      selectedDays: _selectedDays,
      targetDays: _targetDays,
      period: _period,
      startDate: _startDate,
      endDate: _endDate,
      color: _color,
      targetCompletionType: _targetCompletionType,
      unit: _type == HabitType.numeric && _unitController.text.isNotEmpty
          ? _unitController.text
          : null,
    );
  }

  Widget _buildSelectionTile<T>({
    required T value,
    required T groupValue,
    required String title,
    required IconData icon,
    String? subtitle,
    required ValueChanged<T> onChanged,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return Card(
      elevation: 0,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : null,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected ? theme.colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Color?> showColorPicker() async {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.lightBlue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ]
                .map((color) => InkWell(
                      onTap: () => Navigator.pop(context, color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text([
          'New Habit',
          'Type',
          'Frequency',
          'Schedule',
          'Settings',
          'Review',
        ][_currentStep]),
        leading: _currentStep == 0
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  [
                    _buildBasicInfoStep(),
                    _buildTypeStep(),
                    _buildFrequencyStep(),
                    _buildScheduleStep(),
                    _buildSettingsStep(),
                    _buildReviewStep(),
                  ][_currentStep],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _previousStep,
                  child: const Text('Previous'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _nextStep,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : Text(_currentStep == 5 ? 'Create Habit' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
