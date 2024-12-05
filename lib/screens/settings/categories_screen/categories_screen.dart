import 'package:flutter/material.dart';

import 'package:signals/signals_flutter.dart';

import 'package:habits/models/category.dart';
import 'package:habits/screens/settings/categories_screen/widgets/category_form_screen.dart';
import 'package:habits/services/service_locator.dart';

class CategoriesScreen extends StatelessWidget {
  final bool isSelectionMode;
  final Function(Category)? onCategorySelected;

  const CategoriesScreen({
    super.key,
    this.isSelectionMode = false,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryService = serviceLocator.categoryService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Watch((context) {
        final ids = categoryService.categoryIds.value;
        final categories =
            ids.map((id) => categoryService.getCategoryById(id)).toList();

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No categories yet',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                if (!isSelectionMode)
                  FilledButton.icon(
                    onPressed: () => _openCategoryForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(category.color).withOpacity(0.2),
                        child: Icon(
                          category.icon,
                          color: Color(category.color),
                          size: 24,
                        ),
                      ),
                      title: Text(category.name),
                      subtitle: category.description != null
                          ? Text(category.description!)
                          : null,
                      trailing: isSelectionMode
                          ? const Icon(Icons.chevron_right)
                          : null,
                      onTap: isSelectionMode
                          ? () => onCategorySelected?.call(category)
                          : () => _openCategoryForm(context, category),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
      floatingActionButton: !isSelectionMode
          ? FloatingActionButton(
              onPressed: () => _openCategoryForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _openCategoryForm(
    BuildContext context, [
    Category? category,
  ]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(
          initialCategory: category,
        ),
      ),
    );
  }
}
