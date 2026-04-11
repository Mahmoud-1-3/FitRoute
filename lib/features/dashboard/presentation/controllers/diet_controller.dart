import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/meal_model.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../shared/data/diet_repository.dart';

/// ─── Diet Controller ───────────────────────────────────────────────────────
/// Exposes the daily meal list and handles **radio-button** selection with
/// **sequential category locking**:
///   – Categories must be completed in order: Breakfast → Lunch → Snack → Dinner.
///   – Only ONE meal per category can be selected at a time.
///   – A category is "completed" when one meal from it is selected.
///   – Users cannot select a meal from a later category until all previous
///     categories are completed.
///   – Changes are persisted back to Hive.

class DietController extends StateNotifier<List<MealModel>> {
  DietController(this._repo) : super(_repo.getDailyMeals()) {
    _box = Hive.box<MealModel>(LocalStorageService.dietBox);
    _box.listenable().addListener(_onBoxChanged);
  }

  final DietRepository _repo;
  late final Box<MealModel> _box;

  void _onBoxChanged() {
    if (mounted) {
      state = _repo.getDailyMeals();
    }
  }

  /// Ordered list of meal categories – the sequence users must follow.
  static const List<String> categoryOrder = [
    'Breakfast',
    'Lunch',
    'Snack',
    'Dinner',
  ];

  /// Suggested time label for each category.
  static const Map<String, String> categoryTimes = {
    'Breakfast': '8:00 AM',
    'Lunch': '12:30 PM',
    'Snack': '3:30 PM',
    'Dinner': '7:00 PM',
  };

  /// Returns the first category that does NOT yet have a selected meal,
  /// or `null` if all categories are completed.
  String? get activeCategory {
    for (final cat in categoryOrder) {
      final hasSelection = state.any((m) => m.category == cat && m.isSelected);
      if (!hasSelection) return cat;
    }
    return null; // all done!
  }

  /// Whether a particular category is unlocked (current or already completed).
  bool isCategoryUnlocked(String category) {
    final active = activeCategory;
    if (active == null) return true; // all done → everything unlocked
    final activeIdx = categoryOrder.indexOf(active);
    final catIdx = categoryOrder.indexOf(category);
    return catIdx <= activeIdx;
  }

  /// Select a meal. Enforces sequential locking:
  ///   – If the meal's category is locked, do nothing.
  ///   – Otherwise, radio-button behaviour within the category.
  Future<void> toggleMealSelection(String mealId) async {
    // Find the tapped meal.
    final tapped = state.firstWhere(
      (m) => m.id == mealId,
      orElse: () => state.first,
    );

    // If we're deselecting it, simply toggle off.
    if (tapped.isSelected) {
      await _repo.toggleMealSelection(mealId);
      state = _repo.getDailyMeals();
      return;
    }

    // Block if category is locked.
    if (!isCategoryUnlocked(tapped.category)) return;

    // Deselect the current pick in the same category first.
    final currentPick = state
        .where((m) => m.category == tapped.category && m.isSelected)
        .toList();
    for (final old in currentPick) {
      await _repo.toggleMealSelection(old.id); // deselect old
    }

    // Then select the new one.
    await _repo.toggleMealSelection(mealId);
    state = _repo.getDailyMeals(); // re-read from Hive
  }

  /// Force reload from Hive (useful after plan regeneration).
  void refresh() {
    state = _repo.getDailyMeals();
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final dietControllerProvider =
    StateNotifierProvider<DietController, List<MealModel>>((ref) {
      final repo = ref.read(dietRepositoryProvider);
      return DietController(repo);
    });
