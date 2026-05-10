import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/meal_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/diet_controller.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/quick_action_cards.dart';
import '../widgets/weight_progress_chart.dart';

/// ─── User Home Screen ──────────────────────────────────────────────────────
/// The "Welcome back" dashboard: greeting, calorie ring, macros, chart, cards.

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Read user profile from Hive ──
    final user = ref.watch(userProvider);
    final fullName = user?.fullName ?? 'User';

    // ── Read meals for calorie & macro totals ──
    final meals = ref.watch(dietControllerProvider);
    final selectedMeals = meals.where((m) => m.isSelected).toList();

    final consumed = selectedMeals.fold<int>(0, (s, m) => s + m.calories);
    final carbsG = selectedMeals.fold<int>(0, (s, m) => s + m.carbs);
    final proteinG = selectedMeals.fold<int>(0, (s, m) => s + m.protein);
    final fatG = selectedMeals.fold<int>(0, (s, m) => s + m.fat);

    // Daily goal = one meal per category (all options share the same cal).
    // Pick the first meal from each unique category to get the true target.
    final categories = <String, MealModel>{};
    for (final m in meals) {
      categories.putIfAbsent(m.category, () => m);
    }
    final goalMeals = categories.values.toList();
    final goalCal = goalMeals.fold<int>(0, (s, m) => s + m.calories);
    final carbsGoal = goalMeals.fold<int>(0, (s, m) => s + m.carbs);
    final proteinGoal = goalMeals.fold<int>(0, (s, m) => s + m.protein);
    final fatGoal = goalMeals.fold<int>(0, (s, m) => s + m.fat);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Calorie & Macro card (driven by Hive data) ──
              CalorieSummaryCard(
                consumed: consumed,
                goal: goalCal > 0 ? goalCal : 2100,
                carbsG: carbsG,
                carbsGoal: carbsGoal > 0 ? carbsGoal : 200,
                proteinG: proteinG,
                proteinGoal: proteinGoal > 0 ? proteinGoal : 130,
                fatG: fatG,
                fatGoal: fatGoal > 0 ? fatGoal : 70,
              ),
              const SizedBox(height: 20),

              // ── Weight chart ──
              const WeightProgressChart(),
              const SizedBox(height: 20),

              // ── Quick actions ──
              const QuickActionCards(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
