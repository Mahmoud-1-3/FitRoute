import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/meal_model.dart';
import '../../../core/services/local_storage_service.dart';

/// ─── Diet Repository ───────────────────────────────────────────────────────
/// Abstracts Hive CRUD for daily meal plans.

class DietRepository {
  DietRepository(this._box);
  final Box<MealModel> _box;

  /// Replace all meals for the day.
  Future<void> saveDailyMeals(List<MealModel> meals) async {
    await _box.clear();
    for (final meal in meals) {
      await _box.put(meal.id, meal);
    }
  }

  /// Get all stored meals.
  List<MealModel> getDailyMeals() {
    return _box.values.toList();
  }

  /// Clear all meals (logout).
  Future<void> clearDiet() async {
    await _box.clear();
  }

  /// Toggle the `isSelected` flag on a specific meal.
  Future<void> toggleMealSelection(String mealId) async {
    final meal = _box.get(mealId);
    if (meal != null) {
      final updated = meal.copyWith(isSelected: !meal.isSelected);
      await _box.put(mealId, updated);
    }
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final dietRepositoryProvider = Provider<DietRepository>((ref) {
  final box = Hive.box<MealModel>(LocalStorageService.dietBox);
  return DietRepository(box);
});
