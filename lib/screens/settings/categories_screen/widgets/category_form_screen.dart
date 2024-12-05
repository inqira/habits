import 'package:flutter/material.dart';

import 'package:habits/constants/habit_icons.dart';
import 'package:habits/models/category.dart';
import 'package:habits/screens/settings/categories_screen/widgets/icon_selector_dialog.dart';
import 'package:habits/services/service_locator.dart';
import 'package:habits/widgets/color_picker.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? initialCategory;

  const CategoryFormScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late String name;
  late String? description;
  late Color color;
  late String iconName;

  @override
  void initState() {
    super.initState();
    name = widget.initialCategory?.name ?? '';
    description = widget.initialCategory?.description;
    color = Color(widget.initialCategory?.color ?? Colors.blue.value);
    iconName = widget.initialCategory?.iconName ?? HabitIcons.defaultIconName;
  }

  void _handleSave() {
    final categoryService = serviceLocator.categoryService;

    if (widget.initialCategory == null) {
      categoryService.addCategory(
        Category.create(
          name: name,
          description: description,
          color: color.value,
          iconName: iconName,
        ),
      );
    } else {
      categoryService.updateCategory(
        widget.initialCategory!,
        name: name,
        description: description,
        color: color.value,
        iconName: iconName,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialCategory == null ? 'New Category' : 'Edit Category'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => name = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 16),
              ColorPicker(
                selectedColor: color,
                onColorSelected: (selectedColor) =>
                    setState(() => color = selectedColor),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(HabitIcons.getIcon(iconName)),
                title: const Text('Icon'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                onTap: () => showIconSelector(
                  context: context,
                  selectedIconName: iconName,
                  onIconSelected: (selectedIcon) =>
                      setState(() => iconName = selectedIcon),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: name.trim().isEmpty ? null : _handleSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
