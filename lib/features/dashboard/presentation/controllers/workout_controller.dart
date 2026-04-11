import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/workout_model.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../shared/data/workout_repository.dart';

/// ─── Workout Controller ────────────────────────────────────────────────────
/// Exposes the workout plan from the local Hive store.

class WorkoutController extends StateNotifier<List<WorkoutModel>> {
  WorkoutController(this._repo) : super(_repo.getWorkouts()) {
    _box = Hive.box<WorkoutModel>(LocalStorageService.workoutBox);
    _box.listenable().addListener(_onBoxChanged);
  }

  final WorkoutRepository _repo;
  late final Box<WorkoutModel> _box;

  void _onBoxChanged() {
    if (mounted) {
      state = _repo.getWorkouts();
    }
  }

  /// Force reload from Hive.
  void refresh() {
    state = _repo.getWorkouts();
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final workoutControllerProvider =
    StateNotifierProvider<WorkoutController, List<WorkoutModel>>((ref) {
      final repo = ref.read(workoutRepositoryProvider);
      return WorkoutController(repo);
    });
