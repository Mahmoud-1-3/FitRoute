import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/meal_ingredients.dart';

/// ─── Meal Detail Screen ────────────────────────────────────────────────────
/// Full breakdown of a single meal: header, calorie ring, macro bars,
/// macro percentage chart, and nutritional details.

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({
    super.key,
    required this.mealId,
    required this.name,
    required this.category,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.isSelected,
  });

  final String mealId;
  final String name;
  final String category;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // ── Macro calorie breakdown ──
    final carbsCal = carbs * 4;
    final proteinCal = protein * 4;
    final fatCal = fat * 9;
    final totalMacroCal = carbsCal + proteinCal + fatCal;

    final carbsPct = totalMacroCal > 0 ? (carbsCal / totalMacroCal * 100) : 0.0;
    final proteinPct = totalMacroCal > 0
        ? (proteinCal / totalMacroCal * 100)
        : 0.0;
    final fatPct = totalMacroCal > 0 ? (fatCal / totalMacroCal * 100) : 0.0;

    // ── Per-ingredient data ──
    final ingredients = getIngredientsForMeal(mealId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _categoryIcon(category),
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Selected badge
                if (isSelected)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Total Calories Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$calories',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Total Calories',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Macro Breakdown Title ──
                  Text(
                    'Macro Breakdown',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Three macro cards ──
                  Row(
                    children: [
                      Expanded(
                        child: _MacroDetailCard(
                          label: 'Carbs',
                          grams: carbs,
                          kcal: carbsCal,
                          percent: carbsPct,
                          color: const Color(0xFF6366F1),
                          icon: Icons.grain_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MacroDetailCard(
                          label: 'Protein',
                          grams: protein,
                          kcal: proteinCal,
                          percent: proteinPct,
                          color: const Color(0xFFF59E0B),
                          icon: Icons.egg_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MacroDetailCard(
                          label: 'Fat',
                          grams: fat,
                          kcal: fatCal,
                          percent: fatPct,
                          color: const Color(0xFFEF4444),
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Macro Percentage Bar ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calorie Distribution',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stacked horizontal bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 14,
                            child: Row(
                              children: [
                                Flexible(
                                  flex: carbsPct.round().clamp(1, 100),
                                  child: Container(
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                                Flexible(
                                  flex: proteinPct.round().clamp(1, 100),
                                  child: Container(
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                Flexible(
                                  flex: fatPct.round().clamp(1, 100),
                                  child: Container(
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _LegendItem(
                              'Carbs',
                              '${carbsPct.round()}%',
                              const Color(0xFF6366F1),
                            ),
                            _LegendItem(
                              'Protein',
                              '${proteinPct.round()}%',
                              const Color(0xFFF59E0B),
                            ),
                            _LegendItem(
                              'Fat',
                              '${fatPct.round()}%',
                              const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Ingredient Breakdown Section ──
                  if (ingredients.isNotEmpty) ...[
                    Text(
                      'Ingredient Breakdown',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...ingredients.map(
                      (ing) => _IngredientCard(ingredient: ing),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Nutritional Details Table ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutritional Details',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _NutrientRow('Total Calories', '$calories kcal'),
                        _NutrientRow(
                          'Carbohydrates',
                          '${carbs}g ($carbsCal kcal)',
                        ),
                        _NutrientRow(
                          'Protein',
                          '${protein}g ($proteinCal kcal)',
                        ),
                        _NutrientRow('Fat', '${fat}g ($fatCal kcal)'),
                        const Divider(height: 20),
                        _NutrientRow(
                          'Carbs per calorie',
                          '${(carbs / (calories > 0 ? calories : 1) * 100).toStringAsFixed(1)}g / 100 kcal',
                        ),
                        _NutrientRow(
                          'Protein per calorie',
                          '${(protein / (calories > 0 ? calories : 1) * 100).toStringAsFixed(1)}g / 100 kcal',
                        ),
                        _NutrientRow(
                          'Fat per calorie',
                          '${(fat / (calories > 0 ? calories : 1) * 100).toStringAsFixed(1)}g / 100 kcal',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.nightlight_round;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_rounded;
    }
  }
}

// ─── Macro Detail Card ──────────────────────────────────────────────────────

class _MacroDetailCard extends StatelessWidget {
  const _MacroDetailCard({
    required this.label,
    required this.grams,
    required this.kcal,
    required this.percent,
    required this.color,
    required this.icon,
  });

  final String label;
  final int grams;
  final int kcal;
  final double percent;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            '${grams}g',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$kcal kcal',
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textHint),
          ),
          const SizedBox(height: 2),
          Text(
            '${percent.round()}%',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend Item ─────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Nutrient Row ───────────────────────────────────────────────────────────

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ingredient Card ────────────────────────────────────────────────────────

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ingredient});
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & serving
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${ingredient.grams.toInt()}g',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${ingredient.calories} kcal',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Macro mini bars
            Row(
              children: [
                _IngredientMacro(
                  'Carbs',
                  '${ingredient.carbs}g',
                  const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                _IngredientMacro(
                  'Protein',
                  '${ingredient.protein}g',
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                _IngredientMacro(
                  'Fat',
                  '${ingredient.fat}g',
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ingredient Macro Chip ──────────────────────────────────────────────────

class _IngredientMacro extends StatelessWidget {
  const _IngredientMacro(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
