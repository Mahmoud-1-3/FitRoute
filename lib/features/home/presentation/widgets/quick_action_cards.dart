import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/diet_controller.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 14) / 2;
        final scale = (cardWidth / 170).clamp(0.75, 1.0);

        return Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: nextMealIcon,
                iconBg: nextMealIconBg,
                iconColor: nextMealIconColor,
                title: nextMealTitle,
                subtitle: nextMealSubtitle,
                detail: nextMealDetail,
                scale: scale,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.fitness_center_rounded,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF8B5CF6),
                title: "Today's Workout",
                subtitle: 'Upper Body',
                detail: '45 min  •  6 exercises',
                scale: scale,
              ),
            ),
          ],
        );
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
    required this.scale,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final pad = (16 * scale).clamp(10.0, 16.0);
    final iconSize = (40 * scale).clamp(28.0, 40.0);
    final iconRadius = (12 * scale).clamp(8.0, 12.0);
    final iconInner = (20 * scale).clamp(14.0, 20.0);

    return Container(
      padding: EdgeInsets.all(pad),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(iconRadius),
            ),
            child: Icon(icon, color: iconColor, size: iconInner),
          ),
          SizedBox(height: 10 * scale),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: (11 * scale).clamp(9.0, 11.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              detail,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
