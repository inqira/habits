import 'package:flutter/material.dart';

import 'package:habits/models/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: FilterChip(
                label: const Text('All'),
                avatar: const Icon(Icons.category_outlined),
                selected: selectedCategoryId == null,
                onSelected: (_) => onCategorySelected(null),
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: Icon(
                category.icon,
                color: selectedCategoryId == category.id
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: Text(category.name),
              selected: category.id == selectedCategoryId,
              onSelected: (_) => onCategorySelected(category.id),
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          );
        },
      ),
    );
  }
}
