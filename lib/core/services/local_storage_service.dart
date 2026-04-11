import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';
import '../models/nutritionist_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

/// ─── Local Storage Service ─────────────────────────────────────────────────
/// Handles Hive initialization, adapter registration, and box management.
///
/// Usage:
///   await ref.read(localStorageProvider).init();

class LocalStorageService {
  /// Box names — single source of truth.
  static const String userBox = 'userBox';
  static const String dietBox = 'dietBox';
  static const String workoutBox = 'workoutBox';
  static const String nutritionistBox = 'nutritionistBox';

  /// Initialise Hive, register adapters, and open core boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    // Register generated adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(NutritionistModelAdapter());
    Hive.registerAdapter(MealModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<MealModel>(dietBox);
    await Hive.openBox<WorkoutModel>(workoutBox);
    await Hive.openBox<NutritionistModel>(nutritionistBox);
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
