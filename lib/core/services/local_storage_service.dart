import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';
import '../models/nutritionist_model.dart';
import '../models/user_model.dart';
import '../models/weight_entry_model.dart';
import '../models/workout_model.dart';

/// ─── Local Storage Service ─────────────────────────────────────────────────
/// Handles Hive initialization, adapter registration, and box management.
///
/// Usage:
///   await ref.read(localStorageProvider).init();

class LocalStorageService {
  /// Box names — single source of truth.
  static const String userBox = 'userBox_v2';
  static const String dietBox = 'dietBox_v2';
  static const String workoutBox = 'workoutBox_v2';
  static const String nutritionistBox = 'nutritionistBox_v2';

  /// Initialise Hive, register adapters, and open core boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    // Register generated adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(NutritionistModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());
    Hive.registerAdapter(WeightEntryAdapter());

    // Open boxes with schema mismatch protection
    await _safeOpenBox<UserModel>(userBox);
    await _safeOpenBox<MealModel>(dietBox);
    await _safeOpenBox<WorkoutModel>(workoutBox);
    await _safeOpenBox<NutritionistModel>(nutritionistBox);
  }

  /// Safely open a box. If a type mismatch occurs (e.g. after changing model schema),
  /// this will catch the error, delete the corrupted/outdated box, and recreate it.
  Future<void> _safeOpenBox<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('⚠️ Schema mismatch detected in $boxName. Wiping box: $e');
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    }
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
