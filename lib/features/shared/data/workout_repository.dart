import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/workout_model.dart';
import '../../../core/services/local_storage_service.dart';

/// ─── Workout Repository ────────────────────────────────────────────────────
/// Abstracts Hive CRUD for workout plans.

class WorkoutRepository {
  WorkoutRepository(this._box);
  final Box<WorkoutModel> _box;

  /// Replace all workouts.
  Future<void> saveWorkouts(List<WorkoutModel> workouts) async {
    await _box.clear();
    for (final w in workouts) {
      await _box.put(w.id, w);
    }
  }

  /// Get all stored workouts.
  List<WorkoutModel> getWorkouts() {
    return _box.values.toList();
  }

  /// Clear all workouts (logout).
  Future<void> clearWorkouts() async {
    await _box.clear();
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final box = Hive.box<WorkoutModel>(LocalStorageService.workoutBox);
  return WorkoutRepository(box);
});
