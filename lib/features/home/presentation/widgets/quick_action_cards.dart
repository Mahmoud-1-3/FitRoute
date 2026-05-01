import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/diet_controller.dart';
import '../../../dashboard/presentation/screens/user_main_shell.dart';

/// ─── Quick Action Cards ────────────────────────────────────────────────────
/// "Next Meal" and "Today's Workout" preview cards for the dashboard.
/// The "Next Meal" card dynamically shows the current active category
/// based on which meals the user has already completed.

class QuickActionCards extends ConsumerWidget {
  const QuickActionCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(dietControllerProvider);
    final controller = ref.read(dietControllerProvider.notifier);
    final activeCat = controller.activeCategory;

    // Determine "Next Meal" info
    String nextMealTitle;
    String nextMealSubtitle;
    String nextMealDetail;
    IconData nextMealIcon;
    Color nextMealIconBg;
    Color nextMealIconColor;

    if (activeCat != null) {
      // Find the selected meal in the active category (if any), or
      // show the first option as a preview.
      final catMeals = meals.where((m) => m.category == activeCat).toList();
      final selected = catMeals.where((m) => m.isSelected).toList();
      final preview = selected.isNotEmpty
          ? selected.first
          : (catMeals.isNotEmpty ? catMeals.first : null);
      final time = DietController.categoryTimes[activeCat] ?? '';

      nextMealTitle = 'Next Meal';
      nextMealSubtitle = activeCat;
      nextMealDetail = preview != null
          ? '${preview.calories} kcal  •  $time'
          : 'Loading...';
      nextMealIcon = _categoryIcon(activeCat);
      nextMealIconBg = const Color(0xFFFEF3C7);
      nextMealIconColor = const Color(0xFFF59E0B);
    } else {
      nextMealTitle = 'All Done!';
      nextMealSubtitle = 'Meals Complete 🎉';
      nextMealDetail = 'Great job today!';
      nextMealIcon = Icons.check_circle_rounded;
      nextMealIconBg = const Color(0xFFD1FAE5);
      nextMealIconColor = const Color(0xFF10B981);
    }

    return _ActionCard(
      icon: nextMealIcon,
      iconBg: nextMealIconBg,
      iconColor: nextMealIconColor,
      title: nextMealTitle,
      subtitle: nextMealSubtitle,
      detail: nextMealDetail,
      onTap: () {
        ref.read(mainShellTabProvider.notifier).state = 1; // 1 is the Diet tab index
      },
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Breakfast':
        return Icons.free_breakfast_rounded;
      case 'Lunch':
        return Icons.lunch_dining_rounded;
      case 'Snack':
        return Icons.cookie_outlined;
      case 'Dinner':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_rounded;
    }
  }
}

// ─── Single Action Card ─────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: iconColor,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
