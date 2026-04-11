/// ─── Meal Ingredients Data ──────────────────────────────────────────────────
/// Static lookup of ingredient-level macro breakdowns for each meal.
/// Keyed by meal ID (from PlanGeneratorService).
///
/// Each ingredient has: name, grams, calories, carbs (g), protein (g), fat (g).

class Ingredient {
  const Ingredient({
    required this.name,
    required this.grams,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final String name;
  final double grams;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
}

/// Returns the ingredient list for a given meal ID.
/// If no data is found, returns an empty list.
List<Ingredient> getIngredientsForMeal(String mealId) {
  return _ingredientMap[mealId] ?? [];
}

// ═══════════════════════════════════════════════════════════════════════════
// LOSE WEIGHT meals
// ═══════════════════════════════════════════════════════════════════════════

const Map<String, List<Ingredient>> _ingredientMap = {
  // ── Breakfast ──────────────────────────────────────────────────────────
  'bf_lw_1': [
    Ingredient(
      name: 'Egg Whites (6 large)',
      grams: 200,
      calories: 102,
      carbs: 2,
      protein: 22,
      fat: 0,
    ),
    Ingredient(
      name: 'Fresh Spinach',
      grams: 100,
      calories: 23,
      carbs: 4,
      protein: 3,
      fat: 0,
    ),
    Ingredient(
      name: 'Olive Oil Spray',
      grams: 5,
      calories: 40,
      carbs: 0,
      protein: 0,
      fat: 5,
    ),
    Ingredient(
      name: 'Cherry Tomatoes',
      grams: 80,
      calories: 14,
      carbs: 3,
      protein: 1,
      fat: 0,
    ),
  ],
  'bf_lw_2': [
    Ingredient(
      name: 'Greek Yogurt (non-fat)',
      grams: 200,
      calories: 130,
      carbs: 9,
      protein: 23,
      fat: 1,
    ),
    Ingredient(
      name: 'Mixed Berries',
      grams: 120,
      calories: 57,
      carbs: 14,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Honey',
      grams: 10,
      calories: 30,
      carbs: 8,
      protein: 0,
      fat: 0,
    ),
    Ingredient(
      name: 'Chia Seeds',
      grams: 10,
      calories: 49,
      carbs: 4,
      protein: 2,
      fat: 3,
    ),
  ],
  'bf_lw_3': [
    Ingredient(
      name: 'Banana',
      grams: 120,
      calories: 105,
      carbs: 27,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Spinach Leaves',
      grams: 60,
      calories: 14,
      carbs: 2,
      protein: 2,
      fat: 0,
    ),
    Ingredient(
      name: 'Whey Protein Powder',
      grams: 30,
      calories: 120,
      carbs: 3,
      protein: 24,
      fat: 1,
    ),
    Ingredient(
      name: 'Almond Milk',
      grams: 200,
      calories: 30,
      carbs: 1,
      protein: 1,
      fat: 3,
    ),
  ],

  // ── Lunch ──────────────────────────────────────────────────────────────
  'lu_lw_1': [
    Ingredient(
      name: 'Chicken Breast (grilled)',
      grams: 180,
      calories: 280,
      carbs: 0,
      protein: 53,
      fat: 6,
    ),
    Ingredient(
      name: 'Mixed Salad Greens',
      grams: 120,
      calories: 20,
      carbs: 4,
      protein: 2,
      fat: 0,
    ),
    Ingredient(
      name: 'Olive Oil Dressing',
      grams: 15,
      calories: 120,
      carbs: 0,
      protein: 0,
      fat: 14,
    ),
    Ingredient(
      name: 'Cucumber',
      grams: 100,
      calories: 15,
      carbs: 4,
      protein: 1,
      fat: 0,
    ),
  ],
  'lu_lw_2': [
    Ingredient(
      name: 'Turkey Breast (sliced)',
      grams: 150,
      calories: 190,
      carbs: 0,
      protein: 41,
      fat: 2,
    ),
    Ingredient(
      name: 'Lettuce Leaves',
      grams: 80,
      calories: 12,
      carbs: 2,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Avocado (half)',
      grams: 50,
      calories: 80,
      carbs: 4,
      protein: 1,
      fat: 7,
    ),
    Ingredient(
      name: 'Tomato Slices',
      grams: 60,
      calories: 11,
      carbs: 2,
      protein: 1,
      fat: 0,
    ),
  ],
  'lu_lw_3': [
    Ingredient(
      name: 'White Fish Fillet (steamed)',
      grams: 200,
      calories: 200,
      carbs: 0,
      protein: 42,
      fat: 2,
    ),
    Ingredient(
      name: 'Steamed Broccoli',
      grams: 150,
      calories: 52,
      carbs: 10,
      protein: 4,
      fat: 1,
    ),
    Ingredient(
      name: 'Steamed Carrots',
      grams: 100,
      calories: 41,
      carbs: 10,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Lemon Juice',
      grams: 15,
      calories: 4,
      carbs: 1,
      protein: 0,
      fat: 0,
    ),
  ],

  // ── Dinner ─────────────────────────────────────────────────────────────
  'di_lw_1': [
    Ingredient(
      name: 'Salmon Fillet (baked)',
      grams: 180,
      calories: 367,
      carbs: 0,
      protein: 40,
      fat: 22,
    ),
    Ingredient(
      name: 'Steamed Broccoli',
      grams: 150,
      calories: 52,
      carbs: 10,
      protein: 4,
      fat: 1,
    ),
    Ingredient(
      name: 'Lemon & Herbs',
      grams: 10,
      calories: 5,
      carbs: 1,
      protein: 0,
      fat: 0,
    ),
  ],
  'di_lw_2': [
    Ingredient(
      name: 'Shrimp (grilled)',
      grams: 200,
      calories: 200,
      carbs: 2,
      protein: 42,
      fat: 2,
    ),
    Ingredient(
      name: 'Zucchini Noodles',
      grams: 250,
      calories: 42,
      carbs: 8,
      protein: 3,
      fat: 1,
    ),
    Ingredient(
      name: 'Garlic & Olive Oil',
      grams: 10,
      calories: 80,
      carbs: 1,
      protein: 0,
      fat: 9,
    ),
  ],
  'di_lw_3': [
    Ingredient(
      name: 'Lean Beef Strips',
      grams: 180,
      calories: 306,
      carbs: 0,
      protein: 46,
      fat: 12,
    ),
    Ingredient(
      name: 'Bell Peppers',
      grams: 100,
      calories: 31,
      carbs: 6,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Onions',
      grams: 50,
      calories: 20,
      carbs: 5,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Soy Sauce (low sodium)',
      grams: 15,
      calories: 8,
      carbs: 1,
      protein: 1,
      fat: 0,
    ),
  ],

  // ── Snack ──────────────────────────────────────────────────────────────
  'sn_lw_1': [
    Ingredient(
      name: 'Celery Sticks',
      grams: 150,
      calories: 24,
      carbs: 4,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Hummus',
      grams: 60,
      calories: 100,
      carbs: 8,
      protein: 5,
      fat: 6,
    ),
  ],
  'sn_lw_2': [
    Ingredient(
      name: 'Whey Protein Isolate',
      grams: 30,
      calories: 110,
      carbs: 2,
      protein: 25,
      fat: 1,
    ),
    Ingredient(
      name: 'Water / Almond Milk',
      grams: 300,
      calories: 15,
      carbs: 1,
      protein: 1,
      fat: 1,
    ),
  ],
  'sn_lw_3': [
    Ingredient(
      name: 'Low-fat Cottage Cheese',
      grams: 150,
      calories: 110,
      carbs: 5,
      protein: 18,
      fat: 2,
    ),
    Ingredient(
      name: 'Cucumber Slices',
      grams: 100,
      calories: 15,
      carbs: 4,
      protein: 1,
      fat: 0,
    ),
  ],

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD MUSCLE meals
  // ═══════════════════════════════════════════════════════════════════════

  // ── Breakfast ──────────────────────────────────────────────────────────
  'bf_bm_1': [
    Ingredient(
      name: 'Pancake Mix',
      grams: 100,
      calories: 250,
      carbs: 45,
      protein: 7,
      fat: 5,
    ),
    Ingredient(
      name: 'Peanut Butter',
      grams: 30,
      calories: 188,
      carbs: 6,
      protein: 8,
      fat: 16,
    ),
    Ingredient(
      name: 'Banana',
      grams: 120,
      calories: 105,
      carbs: 27,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Maple Syrup',
      grams: 20,
      calories: 52,
      carbs: 13,
      protein: 0,
      fat: 0,
    ),
  ],
  'bf_bm_2': [
    Ingredient(
      name: 'Whey Protein Powder',
      grams: 40,
      calories: 160,
      carbs: 4,
      protein: 32,
      fat: 2,
    ),
    Ingredient(
      name: 'Whole Milk',
      grams: 250,
      calories: 150,
      carbs: 12,
      protein: 8,
      fat: 8,
    ),
    Ingredient(
      name: 'Granola',
      grams: 60,
      calories: 264,
      carbs: 36,
      protein: 6,
      fat: 10,
    ),
  ],
  'bf_bm_3': [
    Ingredient(
      name: 'Bread Slices (2)',
      grams: 80,
      calories: 200,
      carbs: 38,
      protein: 7,
      fat: 2,
    ),
    Ingredient(
      name: 'Eggs (2 whole)',
      grams: 100,
      calories: 155,
      carbs: 1,
      protein: 13,
      fat: 11,
    ),
    Ingredient(
      name: 'Honey',
      grams: 20,
      calories: 60,
      carbs: 16,
      protein: 0,
      fat: 0,
    ),
    Ingredient(
      name: 'Cinnamon',
      grams: 2,
      calories: 5,
      carbs: 2,
      protein: 0,
      fat: 0,
    ),
  ],

  // ── Lunch ──────────────────────────────────────────────────────────────
  'lu_bm_1': [
    Ingredient(
      name: 'Chicken Breast',
      grams: 200,
      calories: 330,
      carbs: 0,
      protein: 62,
      fat: 7,
    ),
    Ingredient(
      name: 'Brown Rice',
      grams: 200,
      calories: 220,
      carbs: 46,
      protein: 5,
      fat: 2,
    ),
    Ingredient(
      name: 'Broccoli',
      grams: 100,
      calories: 35,
      carbs: 7,
      protein: 3,
      fat: 0,
    ),
    Ingredient(
      name: 'Teriyaki Sauce',
      grams: 20,
      calories: 30,
      carbs: 7,
      protein: 1,
      fat: 0,
    ),
  ],
  'lu_bm_2': [
    Ingredient(
      name: 'Lean Ground Beef',
      grams: 150,
      calories: 340,
      carbs: 0,
      protein: 34,
      fat: 22,
    ),
    Ingredient(
      name: 'Pasta (cooked)',
      grams: 200,
      calories: 260,
      carbs: 50,
      protein: 9,
      fat: 2,
    ),
    Ingredient(
      name: 'Parmesan Cheese',
      grams: 20,
      calories: 80,
      carbs: 1,
      protein: 7,
      fat: 5,
    ),
    Ingredient(
      name: 'Marinara Sauce',
      grams: 80,
      calories: 35,
      carbs: 7,
      protein: 1,
      fat: 0,
    ),
  ],
  'lu_bm_3': [
    Ingredient(
      name: 'Canned Tuna',
      grams: 150,
      calories: 165,
      carbs: 0,
      protein: 36,
      fat: 2,
    ),
    Ingredient(
      name: 'Whole Wheat Bread (2)',
      grams: 80,
      calories: 180,
      carbs: 34,
      protein: 7,
      fat: 2,
    ),
    Ingredient(
      name: 'Sweet Potato (baked)',
      grams: 200,
      calories: 180,
      carbs: 41,
      protein: 4,
      fat: 0,
    ),
    Ingredient(
      name: 'Mayonnaise (light)',
      grams: 15,
      calories: 35,
      carbs: 1,
      protein: 0,
      fat: 3,
    ),
  ],

  // ── Dinner ─────────────────────────────────────────────────────────────
  'di_bm_1': [
    Ingredient(
      name: 'Beef Steak (sirloin)',
      grams: 250,
      calories: 500,
      carbs: 0,
      protein: 62,
      fat: 26,
    ),
    Ingredient(
      name: 'Mashed Potatoes',
      grams: 200,
      calories: 230,
      carbs: 34,
      protein: 4,
      fat: 9,
    ),
    Ingredient(
      name: 'Butter',
      grams: 10,
      calories: 72,
      carbs: 0,
      protein: 0,
      fat: 8,
    ),
  ],
  'di_bm_2': [
    Ingredient(
      name: 'Salmon Fillet',
      grams: 200,
      calories: 410,
      carbs: 0,
      protein: 44,
      fat: 25,
    ),
    Ingredient(
      name: 'Pasta (cooked)',
      grams: 180,
      calories: 234,
      carbs: 45,
      protein: 8,
      fat: 2,
    ),
    Ingredient(
      name: 'Alfredo Sauce',
      grams: 60,
      calories: 120,
      carbs: 4,
      protein: 3,
      fat: 10,
    ),
  ],
  'di_bm_3': [
    Ingredient(
      name: 'Chicken Breast',
      grams: 180,
      calories: 280,
      carbs: 0,
      protein: 53,
      fat: 6,
    ),
    Ingredient(
      name: 'White Rice',
      grams: 200,
      calories: 260,
      carbs: 57,
      protein: 5,
      fat: 1,
    ),
    Ingredient(
      name: 'Black Beans',
      grams: 80,
      calories: 100,
      carbs: 18,
      protein: 7,
      fat: 0,
    ),
    Ingredient(
      name: 'Salsa & Sour Cream',
      grams: 40,
      calories: 45,
      carbs: 4,
      protein: 1,
      fat: 3,
    ),
  ],

  // ── Snack ──────────────────────────────────────────────────────────────
  'sn_bm_1': [
    Ingredient(
      name: 'Trail Mix',
      grams: 50,
      calories: 230,
      carbs: 20,
      protein: 6,
      fat: 15,
    ),
    Ingredient(
      name: 'Protein Bar',
      grams: 60,
      calories: 200,
      carbs: 22,
      protein: 20,
      fat: 7,
    ),
  ],
  'sn_bm_2': [
    Ingredient(
      name: 'Banana (large)',
      grams: 130,
      calories: 112,
      carbs: 29,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Peanut Butter',
      grams: 30,
      calories: 188,
      carbs: 6,
      protein: 8,
      fat: 16,
    ),
  ],
  'sn_bm_3': [
    Ingredient(
      name: 'Mass Gainer Powder',
      grams: 80,
      calories: 320,
      carbs: 52,
      protein: 24,
      fat: 4,
    ),
    Ingredient(
      name: 'Whole Milk',
      grams: 200,
      calories: 120,
      carbs: 10,
      protein: 6,
      fat: 6,
    ),
  ],

  // ═══════════════════════════════════════════════════════════════════════
  // MAINTAIN meals
  // ═══════════════════════════════════════════════════════════════════════

  // ── Breakfast ──────────────────────────────────────────────────────────
  'bf_mt_1': [
    Ingredient(
      name: 'Rolled Oats',
      grams: 80,
      calories: 300,
      carbs: 54,
      protein: 10,
      fat: 5,
    ),
    Ingredient(
      name: 'Banana',
      grams: 120,
      calories: 105,
      carbs: 27,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Honey',
      grams: 15,
      calories: 45,
      carbs: 12,
      protein: 0,
      fat: 0,
    ),
    Ingredient(
      name: 'Walnuts',
      grams: 15,
      calories: 98,
      carbs: 2,
      protein: 2,
      fat: 10,
    ),
  ],
  'bf_mt_2': [
    Ingredient(
      name: 'Whole Wheat Toast (2)',
      grams: 80,
      calories: 180,
      carbs: 34,
      protein: 7,
      fat: 2,
    ),
    Ingredient(
      name: 'Avocado (half)',
      grams: 70,
      calories: 112,
      carbs: 6,
      protein: 1,
      fat: 10,
    ),
    Ingredient(
      name: 'Eggs (2 fried)',
      grams: 100,
      calories: 180,
      carbs: 1,
      protein: 12,
      fat: 14,
    ),
  ],
  'bf_mt_3': [
    Ingredient(
      name: 'Whole Grain Cereal',
      grams: 60,
      calories: 220,
      carbs: 44,
      protein: 6,
      fat: 2,
    ),
    Ingredient(
      name: 'Whole Milk',
      grams: 200,
      calories: 120,
      carbs: 10,
      protein: 6,
      fat: 6,
    ),
    Ingredient(
      name: 'Strawberries',
      grams: 80,
      calories: 25,
      carbs: 6,
      protein: 1,
      fat: 0,
    ),
  ],

  // ── Lunch ──────────────────────────────────────────────────────────────
  'lu_mt_1': [
    Ingredient(
      name: 'Salmon Fillet (grilled)',
      grams: 180,
      calories: 367,
      carbs: 0,
      protein: 40,
      fat: 22,
    ),
    Ingredient(
      name: 'Quinoa (cooked)',
      grams: 150,
      calories: 180,
      carbs: 30,
      protein: 7,
      fat: 3,
    ),
    Ingredient(
      name: 'Lemon Dressing',
      grams: 15,
      calories: 40,
      carbs: 1,
      protein: 0,
      fat: 4,
    ),
  ],
  'lu_mt_2': [
    Ingredient(
      name: 'Chicken Breast (grilled)',
      grams: 150,
      calories: 248,
      carbs: 0,
      protein: 46,
      fat: 5,
    ),
    Ingredient(
      name: 'Romaine Lettuce',
      grams: 100,
      calories: 17,
      carbs: 3,
      protein: 1,
      fat: 0,
    ),
    Ingredient(
      name: 'Parmesan Cheese',
      grams: 20,
      calories: 80,
      carbs: 1,
      protein: 7,
      fat: 5,
    ),
    Ingredient(
      name: 'Caesar Dressing',
      grams: 25,
      calories: 120,
      carbs: 1,
      protein: 1,
      fat: 13,
    ),
  ],
  'lu_mt_3': [
    Ingredient(
      name: 'Whole Wheat Tortilla',
      grams: 70,
      calories: 180,
      carbs: 30,
      protein: 5,
      fat: 4,
    ),
    Ingredient(
      name: 'Black Beans',
      grams: 80,
      calories: 100,
      carbs: 18,
      protein: 7,
      fat: 0,
    ),
    Ingredient(
      name: 'Mixed Vegetables',
      grams: 100,
      calories: 40,
      carbs: 8,
      protein: 2,
      fat: 0,
    ),
    Ingredient(
      name: 'Guacamole',
      grams: 30,
      calories: 50,
      carbs: 3,
      protein: 1,
      fat: 4,
    ),
  ],

  // ── Dinner ─────────────────────────────────────────────────────────────
  'di_mt_1': [
    Ingredient(
      name: 'Spaghetti (cooked)',
      grams: 200,
      calories: 260,
      carbs: 50,
      protein: 9,
      fat: 2,
    ),
    Ingredient(
      name: 'Lean Ground Beef',
      grams: 100,
      calories: 200,
      carbs: 0,
      protein: 22,
      fat: 12,
    ),
    Ingredient(
      name: 'Marinara Sauce',
      grams: 100,
      calories: 45,
      carbs: 9,
      protein: 2,
      fat: 0,
    ),
    Ingredient(
      name: 'Parmesan Cheese',
      grams: 10,
      calories: 40,
      carbs: 0,
      protein: 4,
      fat: 3,
    ),
  ],
  'di_mt_2': [
    Ingredient(
      name: 'Chicken Breast (grilled)',
      grams: 180,
      calories: 280,
      carbs: 0,
      protein: 53,
      fat: 6,
    ),
    Ingredient(
      name: 'Sweet Potato (baked)',
      grams: 200,
      calories: 180,
      carbs: 41,
      protein: 4,
      fat: 0,
    ),
    Ingredient(
      name: 'Olive Oil',
      grams: 10,
      calories: 88,
      carbs: 0,
      protein: 0,
      fat: 10,
    ),
  ],
  'di_mt_3': [
    Ingredient(
      name: 'Cod Fillet (baked)',
      grams: 200,
      calories: 180,
      carbs: 0,
      protein: 40,
      fat: 2,
    ),
    Ingredient(
      name: 'Brown Rice (cooked)',
      grams: 200,
      calories: 220,
      carbs: 46,
      protein: 5,
      fat: 2,
    ),
    Ingredient(
      name: 'Steamed Green Beans',
      grams: 100,
      calories: 31,
      carbs: 7,
      protein: 2,
      fat: 0,
    ),
  ],

  // ── Snack ──────────────────────────────────────────────────────────────
  'sn_mt_1': [
    Ingredient(
      name: 'Mixed Nuts',
      grams: 30,
      calories: 175,
      carbs: 6,
      protein: 5,
      fat: 15,
    ),
    Ingredient(
      name: 'Dried Fruit Mix',
      grams: 30,
      calories: 90,
      carbs: 22,
      protein: 1,
      fat: 0,
    ),
  ],
  'sn_mt_2': [
    Ingredient(
      name: 'Apple (medium)',
      grams: 180,
      calories: 95,
      carbs: 25,
      protein: 0,
      fat: 0,
    ),
    Ingredient(
      name: 'Peanut Butter',
      grams: 20,
      calories: 125,
      carbs: 4,
      protein: 5,
      fat: 11,
    ),
  ],
  'sn_mt_3': [
    Ingredient(
      name: 'Greek Yogurt (low-fat)',
      grams: 150,
      calories: 100,
      carbs: 7,
      protein: 17,
      fat: 1,
    ),
    Ingredient(
      name: 'Granola',
      grams: 30,
      calories: 132,
      carbs: 18,
      protein: 3,
      fat: 5,
    ),
  ],
};
