import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/models/habit.dart';
import 'package:habits/screens/habit_new/new_habit_screen.dart';
import 'package:habits/services/service_locator.dart';

class DetailsTab extends StatefulWidget {
  const DetailsTab({
    super.key,
    required this.habitId,
  });

  final String habitId;

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  final _habitService = serviceLocator.habitService;
  final _categoryService = serviceLocator.categoryService;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _endDate;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final habit = _habitService.getHabit(widget.habitId);

    if (habit == null) {
      // Handle case where habit is not found
      Navigator.of(context).pop();
      return;
    }

    _titleController = TextEditingController(text: habit.title);
    _descriptionController =
        TextEditingController(text: habit.description ?? '');
    _categoryId = habit.categoryId;
    _endDate = habit.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _habitService.updateHabitWithFields(
        widget.habitId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _categoryId,
        endDate: _endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit updated successfully')),
        );
      }
    } finally {}
  }

  Future<void> _copyHabit(Habit habit) async {
    String? formattedTargetValue;
    if (habit.type == HabitType.duration) {
      final hours = (habit.targetValue ~/ 3600).toString().padLeft(2, '0');
      final minutes =
          ((habit.targetValue % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (habit.targetValue % 60).toString().padLeft(2, '0');
      formattedTargetValue = '$hours:$minutes:$seconds';
    } else {
      formattedTargetValue = habit.targetValue.toString();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NewHabitScreen(
          initialTitle: '${habit.title} (Copy)',
          initialDescription: habit.description,
          initialCategoryId: habit.categoryId.toString(),
          initialType: habit.type,
          initialTargetValue: formattedTargetValue,
          initialFrequencyType: habit.frequencyType,
          initialSelectedDays: habit.selectedDays.toSet(),
          initialTargetDays: habit.targetDays,
          initialPeriod: habit.period,
          initialStartDate: DateTime.now(),
          initialEndDate: habit.endDate,
          initialTargetCompletionType: habit.targetCompletionType,
        ),
      ),
    );
  }

  Future<void> _toggleArchiveHabit(Habit habit) async {
    try {
      await _habitService.toggleHabitArchived(habit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              habit.isArchived
                  ? 'Habit unarchived successfully'
                  : 'Habit archived successfully',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {}
    }
  }

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
      FrequencyType.yearly => 'Every year',
    };
    return text;
  }

  String _getPeriodText(PeriodOfDay period) {
    return switch (period) {
      PeriodOfDay.morning => 'Morning',
      PeriodOfDay.afternoon => 'Afternoon',
      PeriodOfDay.evening => 'Evening',
      PeriodOfDay.anytime => 'Anytime',
    };
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Widget? prefix,
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (prefix != null) ...[
                  prefix,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (editable && onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    tooltip: 'Edit $label',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog({
    required String title,
    required Widget content,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveChanges();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editName() {
    final controller = TextEditingController(text: _titleController.text);
    _showEditDialog(
      title: 'Edit Name',
      content: TextField(
        controller: controller,
        decoration: _buildInputDecoration(
          labelText: 'Name',
          hintText: 'Enter habit name',
        ),
        onChanged: (value) => _titleController.text = value,
      ),
    );
  }

  void _editDescription() {
    final controller = TextEditingController(text: _descriptionController.text);
    _showEditDialog(
      title: 'Edit Description',
      content: TextField(
        controller: controller,
        decoration: _buildInputDecoration(
          labelText: 'Description',
          hintText: 'Enter habit description',
        ),
        onChanged: (value) => _descriptionController.text = value,
      ),
    );
  }

  void _editCategory() {
    _showEditDialog(
      title: 'Edit Category',
      content: Watch((context) {
        final ids = _categoryService.categoryIds.value;
        final categories =
            ids.map((id) => _categoryService.getCategoryById(id)).toList();

        return DropdownButtonFormField<String>(
          value: _categoryId,
          decoration: _buildInputDecoration(labelText: 'Category'),
          items: categories
              .map((category) => DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.icon,
                            size: 16, color: Color(category.color)),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _categoryId = value;
            }
          },
        );
      }),
    );
  }

  Future<void> _editEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (selectedDate != null) {
      setState(() => _endDate = selectedDate);
      await _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final habit = _habitService.getHabit(widget.habitId);
      if (habit == null) {
        return const Center(child: Text('Habit not found'));
      }
      final category = _categoryService.getCategoryById(habit.categoryId);

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(
                  'Basic Information',
                  [
                    _buildInfoRow(
                      'Name',
                      habit.title,
                      prefix: const Icon(Icons.title, size: 16),
                      editable: true,
                      onEdit: _editName,
                    ),
                    _buildInfoRow(
                      'Description',
                      habit.description ?? 'Not set',
                      prefix: const Icon(Icons.description, size: 16),
                      editable: true,
                      onEdit: _editDescription,
                    ),
                    _buildInfoRow(
                      'Category',
                      category.name,
                      prefix: Icon(
                        category.icon,
                        size: 16,
                        color: Color(category.color),
                      ),
                      editable: true,
                      onEdit: _editCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Schedule',
                  [
                    _buildInfoRow(
                      'Time of Day',
                      _getPeriodText(habit.period),
                      prefix: const Icon(Icons.access_time, size: 16),
                    ),
                    _buildInfoRow(
                      'Start Date',
                      DateFormat('MMM d, y').format(habit.startDate),
                      prefix: const Icon(Icons.play_circle_outline, size: 16),
                    ),
                    _buildInfoRow(
                      'End Date',
                      habit.endDate != null
                          ? DateFormat('MMM d, y').format(habit.endDate!)
                          : 'Not set',
                      prefix: const Icon(Icons.stop_circle_outlined, size: 16),
                      editable: true,
                      onEdit: _editEndDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Details',
                  [
                    _buildInfoRow(
                      'Type',
                      switch (habit.type) {
                        HabitType.checkbox => 'Yes/No',
                        HabitType.numeric => 'Numeric',
                        HabitType.duration => 'Duration',
                      },
                      prefix: Icon(
                        habit.type == HabitType.checkbox
                            ? Icons.check_box_outlined
                            : habit.type == HabitType.numeric
                                ? Icons.numbers
                                : Icons.timer,
                        size: 16,
                      ),
                    ),
                    _buildInfoRow(
                      'Frequency Type',
                      switch (habit.frequencyType) {
                        FrequencyType.daily => 'Daily',
                        FrequencyType.weekly => 'Weekly',
                        FrequencyType.monthly => 'Monthly',
                        FrequencyType.yearly => 'Yearly',
                      },
                      prefix: const Icon(Icons.calendar_month, size: 16),
                    ),
                    _buildInfoRow(
                      'Frequency',
                      _getFrequencyText(habit),
                      prefix: const Icon(Icons.repeat, size: 16),
                    ),
                    _buildInfoRow(
                      'Target Value',
                      switch (habit.type) {
                        HabitType.checkbox => 'Not applicable',
                        HabitType.numeric => '${habit.targetValue} times',
                        HabitType.duration =>
                          '${(habit.targetValue ~/ 3600).toString().padLeft(2, '0')}:${((habit.targetValue % 3600) ~/ 60).toString().padLeft(2, '0')}:${(habit.targetValue % 60).toString().padLeft(2, '0')}',
                      },
                      prefix: const Icon(Icons.flag, size: 16),
                    ),
                    if (habit.type == HabitType.numeric ||
                        habit.type == HabitType.duration)
                      _buildInfoRow(
                        'Target Type',
                        switch (habit.targetCompletionType) {
                          TargetCompletionType.atLeast => 'At Least',
                          TargetCompletionType.exactly => 'Exactly',
                          TargetCompletionType.atMost => 'At Most',
                        },
                        prefix: Icon(
                          switch (habit.targetCompletionType) {
                            TargetCompletionType.atLeast => Icons.arrow_upward,
                            TargetCompletionType.exactly => Icons.drag_handle,
                            TargetCompletionType.atMost => Icons.arrow_downward,
                          },
                          size: 16,
                        ),
                      ),
                    _buildInfoRow(
                      'Created At',
                      DateFormat('MMM d, y').format(habit.createdAt),
                      prefix: const Icon(Icons.calendar_today, size: 16),
                    ),
                    if (habit.isArchived)
                      _buildInfoRow(
                        'Archived At',
                        habit.archivedAt != null
                            ? DateFormat('MMM d, y').format(habit.archivedAt!)
                            : 'Not set',
                        prefix: const Icon(Icons.archive, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _copyHabit(habit),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Habit'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _toggleArchiveHabit(habit),
                  icon:
                      Icon(habit.isArchived ? Icons.unarchive : Icons.archive),
                  label: Text(
                      habit.isArchived ? 'Unarchive Habit' : 'Archive Habit'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
