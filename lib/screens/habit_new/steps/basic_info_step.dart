import 'package:flutter/material.dart';

import 'package:habits/models/category.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final InputDecoration Function({required String labelText, String? hintText})
      buildInputDecoration;
  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  const BasicInfoStep({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.buildInputDecoration,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to build a great new habit? Let\'s get started! 🌟',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: titleController,
          decoration: buildInputDecoration(
            labelText: 'Give your habit a name',
            hintText: 'What amazing habit would you like to develop?',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please give your habit a name to continue';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: buildInputDecoration(
            labelText: 'Add a description (Optional)',
            hintText: 'What makes this habit meaningful to you?',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Text(
          'Choose a category',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          Text(
            'No categories available. Create one in settings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          )
        else
          DropdownButtonFormField<String>(
            decoration: buildInputDecoration(
              labelText: 'Category',
              hintText: 'Select a category for your habit',
            ),
            value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id.toString(),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 20,
                      color: Color(category.color),
                    ),
                    const SizedBox(width: 12),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: onCategoryChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
      ],
    );
  }
}
