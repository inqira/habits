import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/constants/habit_icons.dart';
import 'package:habits/repositories/category_repository.dart';

export 'package:habits/models/category.dart';

class CategoryService {
  final CategoryRepository _repository;
  final _categories = signal<Map<String, Category>>({});

  CategoryService(this._repository) {
    _loadCategories();
  }

  Category get defaultCategory => Category(
        id: 'default',
        name: 'N/A',
        color: Colors.red.value,
        createdAt: DateTime.now(),
        iconName: HabitIcons.defaultIconName,
      );

  Map<String, Category> get categories => _categories.value;
  Signal<Map<String, Category>> get categoriesSignal => _categories;
  FlutterComputed<List<String>> get categoryIds =>
      computed(() => _categories.value.keys.toList());

  void _loadCategories() async {
    try {
      final results = await _repository.getAllCategories();
      _categories.value = {
        for (var category in results) category.id.toString(): category
      };
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories.value = {};
    }
  }

  List<Category> getInitialCategories() {
    return [
      Category.create(
        name: 'Quit Bad Habit',
        color: Colors.red.value,
        iconName: HabitIcons.noSmoking,
      ),
      Category.create(
        name: 'Art',
        color: Colors.pink.value,
        iconName: HabitIcons.art,
      ),
      Category.create(
        name: 'Task',
        color: Colors.purple.value,
        iconName: HabitIcons.task,
      ),
      Category.create(
        name: 'Meditation',
        color: Colors.teal.value,
        iconName: HabitIcons.meditate,
      ),
      Category.create(
        name: 'Study',
        color: Colors.blue.value,
        iconName: HabitIcons.study,
      ),
      Category.create(
        name: 'Sports',
        color: Colors.green.value,
        iconName: HabitIcons.bicycle,
      ),
      Category.create(
        name: 'Fitness',
        color: Colors.orange.value,
        iconName: HabitIcons.fitness,
      ),
      Category.create(
        name: 'Entertainment',
        color: Colors.deepPurple.value,
        iconName: HabitIcons.music,
      ),
      Category.create(
        name: 'Social',
        color: Colors.indigo.value,
        iconName: HabitIcons.social,
      ),
      Category.create(
        name: 'Finance',
        color: Colors.lightGreen.value,
        iconName: HabitIcons.budget,
      ),
      Category.create(
        name: 'Health',
        color: Colors.cyan.value,
        iconName: HabitIcons.health,
      ),
      Category.create(
        name: 'Work',
        color: Colors.brown.value,
        iconName: HabitIcons.work,
      ),
      Category.create(
        name: 'Nutrition',
        color: Colors.amber.value,
        iconName: HabitIcons.nutrition,
      ),
      Category.create(
        name: 'Home',
        color: Colors.deepOrange.value,
        iconName: HabitIcons.home,
      ),
      Category.create(
        name: 'Outdoor',
        color: Colors.lime.value,
        iconName: HabitIcons.outdoor,
      ),
      Category.create(
        name: 'Other',
        color: Colors.lightBlue.value,
        iconName: HabitIcons.task,
      ),
    ];
  }

  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await _repository.getAllCategories();
      if (existingCategories.isEmpty) {
        for (final category in getInitialCategories()) {
          try {
            final success = await _repository.insertCategory(category);
            if (success) {
              _categories.value = {
                ..._categories.value,
                category.id: category,
              };
            }
          } catch (e) {
            debugPrint('Error adding default category: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing default categories: $e');
      // Attempt to recover by clearing and reinitializing
      _categories.value = {};
      for (final category in getInitialCategories()) {
        await addCategory(category);
      }
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final success = await _repository.insertCategory(category);
      if (success) {
        _categories.value = {
          ..._categories.value,
          category.id.toString(): category,
        };
      }
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  void updateCategory(
    Category category, {
    String? name,
    String? description,
    int? color,
    String? iconName,
  }) async {
    try {
      final updatedCategory = category.copyWith(
        name: name,
        description: description,
        color: color,
        iconName: iconName,
      );

      final success = await _repository.updateCategory(updatedCategory);
      if (success) {
        _categories.value = {
          ..._categories.value,
          category.id.toString(): updatedCategory,
        };
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  void deleteCategory(Category category) async {
    try {
      final success = await _repository.deleteCategory(category.id.toString());
      if (success) {
        final updatedCategories = Map<String, Category>.from(_categories.value);
        updatedCategories.remove(category.id.toString());
        _categories.value = updatedCategories;
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  Category getCategoryById(String id) {
    return _categories.value[id] ?? defaultCategory;
  }

  Category findByName(String name) {
    return _categories.value.values.firstWhereOrNull(
          (category) => category.name.toLowerCase() == name.toLowerCase(),
        ) ??
        defaultCategory;
  }
}
