import 'package:habits/models/category.dart';
import 'package:habits/repositories/base_repository.dart';

export 'package:habits/models/category.dart';

class CategoryRepository extends BaseRepository {
  static const String table = 'category';

  Future<List<Category>> getAllCategories() async {
    final data = await getAll(table);
    return data.map((json) => Category.fromJson(json)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final data = await getById(table, id);
    return data != null ? Category.fromJson(data) : null;
  }

  Future<bool> insertCategory(Category category) async {
    final result = await insert(table, category.toJson());
    return result > 0;
  }

  Future<bool> updateCategory(Category category) async {
    final result = await update(table, category.toJson(), category.id);
    return result > 0;
  }

  Future<bool> deleteCategory(String id) async {
    final result = await delete(table, id);
    return result > 0;
  }
}
