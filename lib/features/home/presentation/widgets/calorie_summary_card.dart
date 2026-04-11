import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Calorie & Macro Summary Card ──────────────────────────────────────────
/// Large card with a circular calorie ring and 3 macro mini-bars.

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    this.consumed = 1700,
    this.goal = 2100,
    this.carbsG = 120,
    this.carbsGoal = 200,
    this.proteinG = 90,
    this.proteinGoal = 130,
    this.fatG = 45,
    this.fatGoal = 70,
  });

  final int consumed;
  final int goal;
  final int carbsG, carbsGoal;
  final int proteinG, proteinGoal;
  final int fatG, fatGoal;

  @override
  Widget build(BuildContext context) {
    final remaining = (goal - consumed).clamp(0, goal);
    final percent = (consumed / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Title row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Nutrition",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  '${(percent * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Circular progress ──
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: percent,
            animation: true,
            animationDuration: 1000,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$remaining',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'kcal left',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$consumed / $goal kcal',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ── Macros row ──
          Row(
            children: [
              Expanded(
                child: _MacroBar(
                  label: 'Carbs',
                  current: carbsG,
                  goal: carbsGoal,
                  color: const Color(0xFF6366F1), // Indigo
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroBar(
                  label: 'Protein',
                  current: proteinG,
                  goal: proteinGoal,
                  color: const Color(0xFFF59E0B), // Amber
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroBar(
                  label: 'Fat',
                  current: fatG,
                  goal: fatGoal,
                  color: const Color(0xFFEF4444), // Red
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Macro Mini-Bar ─────────────────────────────────────────────────────────

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  final String label;
  final int current;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current}g / ${goal}g',
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textHint),
        ),
      ],
    );
  }
}
