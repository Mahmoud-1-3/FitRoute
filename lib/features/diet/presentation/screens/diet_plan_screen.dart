import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/meal_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/diet_controller.dart';
import '../widgets/meal_card_widget.dart';

/// ─── Diet Plan Screen ──────────────────────────────────────────────────────
/// "Personalized Diet Plans" with date selector, daily summary, and meals
/// driven by the local Hive database.

class DietPlanScreen extends ConsumerWidget {
  const DietPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(dietControllerProvider);

    // Group meals by category.
    final grouped = <String, List<MealModel>>{};
    for (final meal in meals) {
      grouped.putIfAbsent(meal.category, () => []).add(meal);
    }

    // Calculate daily totals for the summary row.
    // Daily target = one meal per category (all options share the same cal).
    final categories = <String, MealModel>{};
    for (final m in meals) {
      categories.putIfAbsent(m.category, () => m);
    }
    final dailyGoal = categories.values.toList();
    final totalCal = dailyGoal.fold<int>(0, (s, m) => s + m.calories);
    final totalCarbs = dailyGoal.fold<int>(0, (s, m) => s + m.carbs);
    final totalProtein = dailyGoal.fold<int>(0, (s, m) => s + m.protein);
    final totalFat = dailyGoal.fold<int>(0, (s, m) => s + m.fat);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: meals.isEmpty
            // ── Empty state ──
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No diet plan generated yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your sign-up to generate\na personalised meal plan.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Header ──
                    Text(
                      'Personalized Diet Plans',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Daily summary (real totals) ──
                    _DailySummaryRow(
                      calories: totalCal,
                      carbs: totalCarbs,
                      protein: totalProtein,
                      fat: totalFat,
                    ),
                    const SizedBox(height: 24),

                    // ── Meal categories (from Hive) ──
                    ...grouped.entries.map((entry) {
                      final controller = ref.read(
                        dietControllerProvider.notifier,
                      );
                      final locked = !controller.isCategoryUnlocked(entry.key);
                      return _MealSection(
                        title: entry.key,
                        icon: _categoryIcon(entry.key),
                        meals: entry.value,
                        isLocked: locked,
                        onToggle: (mealId) {
                          ref
                              .read(dietControllerProvider.notifier)
                              .toggleMealSelection(mealId);
                        },
                      );
                    }),

                    // ── Allergy disclaimer ──
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: const Color(0xFFFFCA28)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'If you have any food allergies or dietary '
                              'restrictions, please consult a doctor or '
                              'certified nutritionist before following '
                              'this plan.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF92400E),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Breakfast':
        return Icons.wb_sunny_outlined;
      case 'Lunch':
        return Icons.restaurant_outlined;
      case 'Dinner':
        return Icons.nightlight_outlined;
      case 'Snack':
        return Icons.cookie_outlined;
      default:
        return Icons.fastfood_outlined;
    }
  }
}

// ─── Date Selector ──────────────────────────────────────────────────────────

// ─── Daily Summary Row ──────────────────────────────────────────────────────

class _DailySummaryRow extends StatelessWidget {
  const _DailySummaryRow({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final int calories;
  final int carbs;
  final int protein;
  final int fat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Calories', '$calories', 'kcal', AppColors.primary),
          _divider(),
          _summaryItem('Carbs', '$carbs', 'g', const Color(0xFF6366F1)),
          _divider(),
          _summaryItem('Protein', '$protein', 'g', const Color(0xFFF59E0B)),
          _divider(),
          _summaryItem('Fat', '$fat', 'g', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppColors.divider);

  Widget _summaryItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          '$label ($unit)',
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ─── Meal Section ───────────────────────────────────────────────────────────

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.title,
    required this.icon,
    required this.meals,
    required this.onToggle,
    this.isLocked = false,
  });

  final String title;
  final IconData icon;
  final List<MealModel> meals;
  final ValueChanged<String> onToggle;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MealCardWidget(
              name: m.name,
              calories: m.calories,
              carbs: m.carbs,
              protein: m.protein,
              fat: m.fat,
              isSelected: m.isSelected,
              isLocked: isLocked,
              onTap: () => onToggle(m.id),
              onInfoTap: () {
                context.push(
                  '/meal-detail',
                  extra: {
                    'mealId': m.id,
                    'name': m.name,
                    'category': m.category,
                    'calories': m.calories,
                    'carbs': m.carbs,
                    'protein': m.protein,
                    'fat': m.fat,
                    'isSelected': m.isSelected,
                  },
                );
              },
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
