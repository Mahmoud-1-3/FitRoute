import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/meal_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/workout_model.dart';

/// ─── Plan Generator Service ────────────────────────────────────────────────
/// Uses the Mifflin-St Jeor equation to compute BMR → TDEE and then
/// generates a starter diet + workout plan tailored to the user's goal.
///
/// Diet plan rules:
///   • 4 categories: Breakfast (25%), Lunch (35%), Dinner (30%), Snack (10%)
///   • 3 meal options per category — all share the SAME calorie budget
///   • Each option has UNIQUE macros appropriate for the food described
///   • Meal content is goal-appropriate:
///       – Lose Weight → lean, low-fat, high-protein foods
///       – Build Muscle → calorie-dense, carb + protein heavy
///       – Maintain → balanced variety
///   • User picks 1 per category → total always = daily target

class PlanGeneratorService {
  // ══════════════════════════════════════════════════════════════════════════
  // BMR & TDEE
  // ══════════════════════════════════════════════════════════════════════════

  double calculateBMR(UserModel user) {
    final base = (10 * user.weight) + (6.25 * user.height) - (5 * user.age);
    return user.gender.toLowerCase() == 'male' ? base + 5 : base - 161;
  }

  double calculateTDEE(UserModel user) {
    return calculateBMR(user) * _activityFactor(user.activityLevel);
  }

  double _activityFactor(String level) {
    if (level.startsWith('Little')) return 1.2;
    if (level.startsWith('Light')) return 1.375;
    if (level.startsWith('Moderate')) return 1.55;
    if (level.startsWith('Heavy')) return 1.725;
    if (level.startsWith('Very')) return 1.9;
    return 1.2;
  }

  int _targetCalories(UserModel user) {
    final tdee = calculateTDEE(user);
    switch (user.goal.toLowerCase()) {
      case 'lose weight':
        return (tdee - 500).round();
      case 'build muscle':
        return (tdee + 500).round();
      default:
        return tdee.round();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Macro Helpers
  // ══════════════════════════════════════════════════════════════════════════

  /// Derive grams from a calorie budget and a macro percentage split.
  ///   1 g carb = 4 kcal · 1 g protein = 4 kcal · 1 g fat = 9 kcal
  int _carbsG(int cal, double pct) => ((cal * pct) / 4).round();
  int _proteinG(int cal, double pct) => ((cal * pct) / 4).round();
  int _fatG(int cal, double pct) => ((cal * pct) / 9).round();

  // ══════════════════════════════════════════════════════════════════════════
  // Diet Plan — 4 categories × 3 options
  // ══════════════════════════════════════════════════════════════════════════

  List<MealModel> generateDietPlan(UserModel user) {
    final target = _targetCalories(user);
    final goal = user.goal.toLowerCase();

    final bfCal = (target * 0.25).round();
    final luCal = (target * 0.35).round();
    final diCal = (target * 0.30).round();
    final snCal = (target * 0.10).round();

    if (goal == 'lose weight') {
      return [
        ..._loseWeightBreakfasts(bfCal),
        ..._loseWeightLunches(luCal),
        ..._loseWeightDinners(diCal),
        ..._loseWeightSnacks(snCal),
      ];
    } else if (goal == 'build muscle') {
      return [
        ..._muscleBreakfasts(bfCal),
        ..._muscleLunches(luCal),
        ..._muscleDinners(diCal),
        ..._muscleSnacks(snCal),
      ];
    } else {
      return [
        ..._maintainBreakfasts(bfCal),
        ..._maintainLunches(luCal),
        ..._maintainDinners(diCal),
        ..._maintainSnacks(snCal),
      ];
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // LOSE WEIGHT — lean, low-fat, high-protein
  // ────────────────────────────────────────────────────────────────────────

  List<MealModel> _loseWeightBreakfasts(int cal) {
    return [
      // High-protein, very low-fat: egg whites + spinach
      MealModel(
        id: 'bf_lw_1',
        name: 'Egg White Omelette & Spinach',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.20),
        protein: _proteinG(cal, 0.55),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
      // Moderate-protein, higher carb: yogurt + berries
      MealModel(
        id: 'bf_lw_2',
        name: 'Greek Yogurt & Berries',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.40),
        fat: _fatG(cal, 0.15),
        imageUrl: '',
      ),
      // Balanced lean: smoothie with greens + whey
      MealModel(
        id: 'bf_lw_3',
        name: 'Veggie Smoothie Bowl',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _loseWeightLunches(int cal) {
    return [
      // Grilled chicken + big salad → very high protein, low fat
      MealModel(
        id: 'lu_lw_1',
        name: 'Grilled Chicken Breast & Salad',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.25),
        protein: _proteinG(cal, 0.50),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
      // Turkey wraps → moderate carb from wrap, high protein
      MealModel(
        id: 'lu_lw_2',
        name: 'Turkey Lettuce Wraps',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.30),
        protein: _proteinG(cal, 0.50),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
      // Steamed fish + veggies → high protein, very low fat, moderate carb
      MealModel(
        id: 'lu_lw_3',
        name: 'Steamed Fish & Vegetables',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.35),
        protein: _proteinG(cal, 0.50),
        fat: _fatG(cal, 0.15),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _loseWeightDinners(int cal) {
    return [
      // Salmon → healthy fats from omega-3, high protein
      MealModel(
        id: 'di_lw_1',
        name: 'Baked Salmon & Steamed Broccoli',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.15),
        protein: _proteinG(cal, 0.50),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Shrimp + zucchini noodles → very lean, high protein, low carb
      MealModel(
        id: 'di_lw_2',
        name: 'Grilled Shrimp & Zucchini Noodles',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.25),
        protein: _proteinG(cal, 0.55),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
      // Lean beef stir-fry → moderate fat, high protein
      MealModel(
        id: 'di_lw_3',
        name: 'Lean Beef Stir-Fry (no oil)',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.30),
        protein: _proteinG(cal, 0.45),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _loseWeightSnacks(int cal) {
    return [
      // Celery + hummus → moderate carb, low protein
      MealModel(
        id: 'sn_lw_1',
        name: 'Celery Sticks & Hummus',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.20),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Protein shake → very high protein, minimal fat
      MealModel(
        id: 'sn_lw_2',
        name: 'Protein Shake (low-fat)',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.20),
        protein: _proteinG(cal, 0.65),
        fat: _fatG(cal, 0.15),
        imageUrl: '',
      ),
      // Cottage cheese + cucumber → high protein, very low fat
      MealModel(
        id: 'sn_lw_3',
        name: 'Cottage Cheese & Cucumber',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.25),
        protein: _proteinG(cal, 0.55),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD MUSCLE — calorie-dense, carb + protein heavy
  // ────────────────────────────────────────────────────────────────────────

  List<MealModel> _muscleBreakfasts(int cal) {
    return [
      // Peanut butter pancakes → high carb, moderate fat from PB
      MealModel(
        id: 'bf_bm_1',
        name: 'Peanut Butter Pancakes & Banana',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.20),
        fat: _fatG(cal, 0.30),
        imageUrl: '',
      ),
      // Protein shake + granola → high protein, high carb from granola
      MealModel(
        id: 'bf_bm_2',
        name: 'Protein Shake & Granola',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.40),
        protein: _proteinG(cal, 0.40),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
      // French toast + honey → very high carb, moderate protein from eggs
      MealModel(
        id: 'bf_bm_3',
        name: 'French Toast & Honey',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.60),
        protein: _proteinG(cal, 0.20),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _muscleLunches(int cal) {
    return [
      // Chicken + brown rice → high carb from rice, high protein from chicken
      MealModel(
        id: 'lu_bm_1',
        name: 'Chicken & Brown Rice Bowl',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.35),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
      // Beef pasta + cheese → high carb from pasta, moderate protein, moderate fat
      MealModel(
        id: 'lu_bm_2',
        name: 'Beef Pasta with Cheese',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.25),
        fat: _fatG(cal, 0.30),
        imageUrl: '',
      ),
      // Tuna sandwich + sweet potato → balanced carb/protein
      MealModel(
        id: 'lu_bm_3',
        name: 'Tuna Sandwich & Sweet Potato',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _muscleDinners(int cal) {
    return [
      // Steak + mashed potatoes → high protein from steak, high carb from potatoes
      MealModel(
        id: 'di_bm_1',
        name: 'Steak & Mashed Potatoes',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.35),
        protein: _proteinG(cal, 0.40),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
      // Salmon + pasta alfredo → high fat from cream sauce, moderate carb
      MealModel(
        id: 'di_bm_2',
        name: 'Salmon & Pasta Alfredo',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.35),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Chicken burrito bowl → high carb from rice + beans, good protein
      MealModel(
        id: 'di_bm_3',
        name: 'Chicken Burrito Bowl',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _muscleSnacks(int cal) {
    return [
      // Trail mix + protein bar → balanced, calorie-dense
      MealModel(
        id: 'sn_bm_1',
        name: 'Trail Mix & Protein Bar',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.40),
        protein: _proteinG(cal, 0.25),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Banana + PB → high carb from banana, high fat from PB
      MealModel(
        id: 'sn_bm_2',
        name: 'Banana & Peanut Butter',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.15),
        fat: _fatG(cal, 0.40),
        imageUrl: '',
      ),
      // Mass gainer shake → very high carb + protein, low fat
      MealModel(
        id: 'sn_bm_3',
        name: 'Mass Gainer Shake',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.55),
        protein: _proteinG(cal, 0.35),
        fat: _fatG(cal, 0.10),
        imageUrl: '',
      ),
    ];
  }

  // ────────────────────────────────────────────────────────────────────────
  // MAINTAIN — balanced variety
  // ────────────────────────────────────────────────────────────────────────

  List<MealModel> _maintainBreakfasts(int cal) {
    return [
      // Oatmeal + banana → high carb, moderate fat
      MealModel(
        id: 'bf_mt_1',
        name: 'Oatmeal & Banana Bowl',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.55),
        protein: _proteinG(cal, 0.15),
        fat: _fatG(cal, 0.30),
        imageUrl: '',
      ),
      // Avocado toast + eggs → high fat from avocado, moderate protein from eggs
      MealModel(
        id: 'bf_mt_2',
        name: 'Avocado Toast & Eggs',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.30),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.40),
        imageUrl: '',
      ),
      // Whole grain cereal + milk → high carb, moderate protein from milk
      MealModel(
        id: 'bf_mt_3',
        name: 'Whole Grain Cereal & Milk',
        category: 'Breakfast',
        calories: cal,
        carbs: _carbsG(cal, 0.60),
        protein: _proteinG(cal, 0.20),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _maintainLunches(int cal) {
    return [
      // Grilled salmon + quinoa → balanced, healthy fats from salmon
      MealModel(
        id: 'lu_mt_1',
        name: 'Grilled Salmon & Quinoa',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.35),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Caesar salad → high protein from chicken, moderate fat from dressing
      MealModel(
        id: 'lu_mt_2',
        name: 'Chicken Caesar Salad',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.25),
        protein: _proteinG(cal, 0.40),
        fat: _fatG(cal, 0.35),
        imageUrl: '',
      ),
      // Veggie + bean wrap → high carb from wrap + beans, low fat
      MealModel(
        id: 'lu_mt_3',
        name: 'Veggie & Bean Wrap',
        category: 'Lunch',
        calories: cal,
        carbs: _carbsG(cal, 0.55),
        protein: _proteinG(cal, 0.25),
        fat: _fatG(cal, 0.20),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _maintainDinners(int cal) {
    return [
      // Pasta + lean meat sauce → high carb from pasta, moderate protein
      MealModel(
        id: 'di_mt_1',
        name: 'Pasta with Lean Meat Sauce',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.25),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
      // Chicken + sweet potato → balanced, moderate everything
      MealModel(
        id: 'di_mt_2',
        name: 'Grilled Chicken & Sweet Potato',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.40),
        protein: _proteinG(cal, 0.35),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
      // Baked cod + brown rice → lean fish, high carb from rice
      MealModel(
        id: 'di_mt_3',
        name: 'Baked Cod & Brown Rice',
        category: 'Dinner',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.40),
        fat: _fatG(cal, 0.15),
        imageUrl: '',
      ),
    ];
  }

  List<MealModel> _maintainSnacks(int cal) {
    return [
      // Mixed nuts + dried fruit → high fat from nuts, high carb from fruit
      MealModel(
        id: 'sn_mt_1',
        name: 'Mixed Nuts & Dried Fruit',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.40),
        protein: _proteinG(cal, 0.10),
        fat: _fatG(cal, 0.50),
        imageUrl: '',
      ),
      // Apple + PB → high carb from apple, high fat from PB
      MealModel(
        id: 'sn_mt_2',
        name: 'Apple & Peanut Butter',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.50),
        protein: _proteinG(cal, 0.10),
        fat: _fatG(cal, 0.40),
        imageUrl: '',
      ),
      // Greek yogurt + granola → high protein from yogurt, high carb from granola
      MealModel(
        id: 'sn_mt_3',
        name: 'Greek Yogurt & Granola',
        category: 'Snack',
        calories: cal,
        carbs: _carbsG(cal, 0.45),
        protein: _proteinG(cal, 0.30),
        fat: _fatG(cal, 0.25),
        imageUrl: '',
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Workout Plan
  // ══════════════════════════════════════════════════════════════════════════

  List<WorkoutModel> generateWorkoutPlan(UserModel user) {
    final goal = user.goal.toLowerCase();
    if (goal == 'lose weight') return _fatLossWorkouts();
    if (goal == 'build muscle') return _muscleGainWorkouts();
    return _maintenanceWorkouts();
  }

  List<WorkoutModel> _fatLossWorkouts() {
    return const [
      WorkoutModel(
        id: 'wk_1',
        name: 'Jumping Jacks',
        targetMuscle: 'Full Body',
        sets: 3,
        reps: 20,
        imageUrl: '',
        instructions: 'Stand upright, jump while spreading legs and arms.',
      ),
      WorkoutModel(
        id: 'wk_2',
        name: 'Burpees',
        targetMuscle: 'Full Body',
        sets: 3,
        reps: 12,
        imageUrl: '',
        instructions: 'Drop to a push-up, jump back up with arms overhead.',
      ),
      WorkoutModel(
        id: 'wk_3',
        name: 'Mountain Climbers',
        targetMuscle: 'Core',
        sets: 3,
        reps: 15,
        imageUrl: '',
        instructions: 'In plank position, alternate driving knees to chest.',
      ),
      WorkoutModel(
        id: 'wk_4',
        name: 'High Knees',
        targetMuscle: 'Legs',
        sets: 3,
        reps: 20,
        imageUrl: '',
        instructions: 'Run in place, lifting knees to hip height.',
      ),
      WorkoutModel(
        id: 'wk_5',
        name: 'Plank Hold',
        targetMuscle: 'Core',
        sets: 3,
        reps: 30,
        imageUrl: '',
        instructions: 'Hold a forearm plank for 30 seconds per set.',
      ),
    ];
  }

  List<WorkoutModel> _muscleGainWorkouts() {
    return const [
      WorkoutModel(
        id: 'wk_1',
        name: 'Barbell Bench Press',
        targetMuscle: 'Chest',
        sets: 4,
        reps: 8,
        imageUrl: '',
        instructions: 'Lie on bench, lower bar to chest, press up explosively.',
      ),
      WorkoutModel(
        id: 'wk_2',
        name: 'Barbell Squats',
        targetMuscle: 'Legs',
        sets: 4,
        reps: 8,
        imageUrl: '',
        instructions: 'Bar on upper back, squat to parallel, drive up.',
      ),
      WorkoutModel(
        id: 'wk_3',
        name: 'Deadlifts',
        targetMuscle: 'Back',
        sets: 4,
        reps: 6,
        imageUrl: '',
        instructions: 'Hinge at hips, grip bar, lift by extending hips.',
      ),
      WorkoutModel(
        id: 'wk_4',
        name: 'Overhead Press',
        targetMuscle: 'Shoulders',
        sets: 3,
        reps: 10,
        imageUrl: '',
        instructions: 'Press barbell overhead from shoulder height.',
      ),
      WorkoutModel(
        id: 'wk_5',
        name: 'Barbell Rows',
        targetMuscle: 'Back',
        sets: 4,
        reps: 8,
        imageUrl: '',
        instructions: 'Bend forward, pull bar to lower chest.',
      ),
    ];
  }

  List<WorkoutModel> _maintenanceWorkouts() {
    return const [
      WorkoutModel(
        id: 'wk_1',
        name: 'Push-ups',
        targetMuscle: 'Chest',
        sets: 3,
        reps: 15,
        imageUrl: '',
        instructions: 'Standard push-up with full range of motion.',
      ),
      WorkoutModel(
        id: 'wk_2',
        name: 'Bodyweight Squats',
        targetMuscle: 'Legs',
        sets: 3,
        reps: 15,
        imageUrl: '',
        instructions: 'Stand shoulder-width, squat to parallel.',
      ),
      WorkoutModel(
        id: 'wk_3',
        name: 'Dumbbell Rows',
        targetMuscle: 'Back',
        sets: 3,
        reps: 12,
        imageUrl: '',
        instructions: 'One arm on bench, pull dumbbell to hip.',
      ),
      WorkoutModel(
        id: 'wk_4',
        name: 'Lunges',
        targetMuscle: 'Legs',
        sets: 3,
        reps: 12,
        imageUrl: '',
        instructions: 'Step forward, lower until both knees are at 90°.',
      ),
      WorkoutModel(
        id: 'wk_5',
        name: 'Plank',
        targetMuscle: 'Core',
        sets: 3,
        reps: 30,
        imageUrl: '',
        instructions: 'Hold forearm plank for 30 seconds per set.',
      ),
    ];
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final planGeneratorProvider = Provider<PlanGeneratorService>((ref) {
  return PlanGeneratorService();
});
