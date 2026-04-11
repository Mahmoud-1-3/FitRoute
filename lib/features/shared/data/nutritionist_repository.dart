import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/nutritionist_model.dart';
import '../../../core/services/local_storage_service.dart';

/// ─── Nutritionist Repository ───────────────────────────────────────────────
/// Abstracts Hive CRUD for the logged-in nutritionist profile.

class NutritionistRepository {
  NutritionistRepository(this._box);
  final Box<NutritionistModel> _box;

  static const String _key = 'current_nutritionist';

  /// Persist the current nutritionist.
  Future<void> saveNutritionist(NutritionistModel nutritionist) async {
    await _box.put(_key, nutritionist);
  }

  /// Retrieve the current nutritionist (or null if not set).
  NutritionistModel? getNutritionist() {
    return _box.get(_key);
  }

  /// Remove the current nutritionist (logout).
  Future<void> deleteNutritionist() async {
    await _box.delete(_key);
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final nutritionistRepositoryProvider = Provider<NutritionistRepository>((ref) {
  final box = Hive.box<NutritionistModel>(LocalStorageService.nutritionistBox);
  return NutritionistRepository(box);
});
